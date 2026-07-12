import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/realtime_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/permission_helper.dart';
import '../../services/history_repository.dart';
import '../../services/ikan_repository.dart';
import '../detail/species_detail_view.dart';

/// Top-1 hasil deteksi live, dibangun dari map mentah `flutter_vision`
/// (`box`: [x1,y1,x2,y2,conf], `tag`: nama kelas) + `classIndex` yang
/// diresolusi lewat `IkanRepository.findByName`.
class _LiveResult {
  final String className;
  final double confidence;
  final int classIndex;
  const _LiveResult({
    required this.className,
    required this.confidence,
    required this.classIndex,
  });
}

class RealtimeView extends StatefulWidget {
  const RealtimeView({super.key});

  @override
  State<RealtimeView> createState() => _RealtimeViewState();
}

class _RealtimeViewState extends State<RealtimeView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Permission & lifecycle
  bool _cameraPermission = false;
  bool _checkingPermission = true;
  bool _isActive = true;

  // Kamera & deteksi
  CameraController? _camera;
  FlutterVision? _vision;
  bool _cameraReady = false;
  bool _isDetecting = false;

  // Detection state
  _LiveResult? _topResult;
  String? _stableClass;
  Timer? _stableTimer;
  bool _isNavigating = false;

  // Progress animation (1.5s)
  late AnimationController _progressCtrl;

  static const _stableDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressCtrl = AnimationController(vsync: this, duration: _stableDuration);
    _checkPermission();
    // Pre-load ikan.json so first navigation is instant
    IkanRepository.loadAll();
  }

  @override
  void dispose() {
    _stableTimer?.cancel();
    _progressCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final resumed = state == AppLifecycleState.resumed;
    setState(() => _isActive = resumed);
    if (!resumed) {
      _resetStable();
      _disposeCamera();
    } else if (_cameraPermission) {
      _initCamera();
    }
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionHelper.requestCamera();
    if (!mounted) return;
    setState(() {
      _cameraPermission = granted;
      _checkingPermission = false;
    });
    if (granted) await _initCamera();
  }

  Future<void> _disposeCamera() async {
    final camera = _camera;
    _camera = null;
    _cameraReady = false;
    if (camera != null) {
      if (camera.value.isStreamingImages) {
        await camera.stopImageStream();
      }
      await camera.dispose();
    }
  }

  Future<void> _initCamera() async {
    try {
      final vision = await context.read<RealtimeController>().ensureModelLoaded();
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream(_onCameraImage);
      setState(() {
        _camera = controller;
        _vision = vision;
        _cameraReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      context.read<RealtimeController>().onViewError(e.toString());
    }
  }

  // ── Detection callback ────────────────────────────────────────────────

  void _onCameraImage(CameraImage image) {
    if (_isDetecting || !_isActive || _isNavigating || _vision == null) return;
    _isDetecting = true;
    _detect(image).whenComplete(() => _isDetecting = false);
  }

  Future<void> _detect(CameraImage image) async {
    try {
      final raw = await _vision!.yoloOnFrame(
        bytesList: image.planes.map((p) => p.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: AppConstants.iouThreshold,
        confThreshold: AppConstants.confidenceThreshold,
        classThreshold: AppConstants.confidenceThreshold,
      );
      await _handleDetectionResult(raw);
    } catch (_) {
      // Frame tunggal gagal diproses — abaikan, coba lagi di frame berikutnya.
    }
  }

  Future<void> _handleDetectionResult(List<Map<String, dynamic>> raw) async {
    if (!mounted || !_isActive || _isNavigating) return;

    // Top-1: ambil kotak dengan confidence tertinggi.
    Map<String, dynamic>? topBox;
    double bestConf = -1;
    for (final r in raw) {
      final conf = ((r['box'] as List)[4] as num).toDouble();
      if (conf > bestConf) {
        bestConf = conf;
        topBox = r;
      }
    }

    _LiveResult? top;
    if (topBox != null) {
      final className = topBox['tag'] as String;
      // Model tidak punya kelas "Non Ikan" sendiri — confidence di bawah
      // identificationThreshold sering merupakan objek non-ikan,
      // reklasifikasi ke "Non Ikan" agar konsisten dengan GalleryController.
      if (bestConf < AppConstants.identificationThreshold) {
        top = _LiveResult(
          className: 'non_ikan',
          confidence: bestConf,
          classIndex: AppConstants.nonFishClassIndex,
        );
      } else {
        final species = await IkanRepository.findByName(className);
        top = _LiveResult(
          className: className,
          confidence: bestConf,
          classIndex: species?.id ?? AppConstants.nonFishClassIndex,
        );
      }
    }

    if (!mounted || !_isActive || _isNavigating) return;

    if (top?.className != _topResult?.className) {
      setState(() => _topResult = top);
    }

    // Tidak ada deteksi → reset stable timer
    if (top == null) {
      _resetStable();
      return;
    }

    // Spesies berubah → reset dan mulai timer baru
    if (top.className != _stableClass) {
      _resetStable();
      _stableClass = top.className;
      // "Non Ikan" tidak memicu navigasi ke halaman detail
      if (top.classIndex == AppConstants.nonFishClassIndex) return;
      _progressCtrl.forward(from: 0);
      _stableTimer = Timer(_stableDuration, () => _navigateToDetail(top!));
    }
  }

  void _resetStable() {
    _stableTimer?.cancel();
    _stableTimer = null;
    _stableClass = null;
    if (_progressCtrl.isAnimating || _progressCtrl.value > 0) {
      _progressCtrl.reset();
    }
  }

  Future<void> _navigateToDetail(_LiveResult detection) async {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    _resetStable();

    // Lookup spesies dari ikan.json
    final species = await IkanRepository.findById(detection.classIndex);
    if (species == null || !mounted) {
      _isNavigating = false;
      return;
    }

    // Capture foto kamera
    Uint8List? photoBytes;
    final camera = _camera;
    try {
      if (camera != null && camera.value.isStreamingImages) {
        await camera.stopImageStream();
      }
      final photo = await camera?.takePicture();
      if (photo != null) photoBytes = await photo.readAsBytes();
    } catch (e) {
      debugPrint('[RealtimeView] gagal mengambil foto: $e');
    }
    if (!mounted) {
      _isNavigating = false;
      return;
    }

    // Pause kamera sebelum push
    setState(() => _isActive = false);

    final timestamp = DateTime.now();
    try {
      await HistoryRepository.add(
        classIndex: detection.classIndex,
        className: species.nama,
        confidence: detection.confidence,
        photo: photoBytes,
      );
    } catch (e) {
      debugPrint('[RealtimeView] gagal menyimpan riwayat: $e');
    }
    if (!mounted) {
      _isNavigating = false;
      return;
    }

    await Navigator.of(context).pushNamed(
      AppConstants.detailRoute,
      arguments: SpeciesDetailArgs(
        className: detection.className,
        confidence: detection.confidence,
        species: species,
        photo: photoBytes,
        timestamp: timestamp,
      ),
    );

    // Resume kamera setelah kembali
    if (mounted) {
      setState(() {
        _isActive = true;
        _isNavigating = false;
        _topResult = null;
      });
      if (_camera != null && !_camera!.value.isStreamingImages) {
        await _camera!.startImageStream(_onCameraImage);
      } else if (_camera == null) {
        await _initCamera();
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_checkingPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    if (!_cameraPermission) {
      return _PermissionDeniedScreen(onRetry: _checkPermission);
    }

    return Consumer<RealtimeController>(
      builder: (context, ctrl, _) {
        if (ctrl.error != null) {
          return _ErrorScreen(message: ctrl.error!);
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (_isActive && _cameraReady && _camera != null)
                _CameraPreviewCover(controller: _camera!)
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              const _TopBar(),
              _DetectionInfoCard(
                topResult: _topResult,
                controller: _progressCtrl,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Camera preview (cover fit, sesuai orientasi sensor) ─────────────────────

class _CameraPreviewCover extends StatelessWidget {
  final CameraController controller;
  const _CameraPreviewCover({required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox();
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  static const _buttonSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.liveDetection,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _buttonSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.black.withValues(alpha: 0.20),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: _TopBar._buttonSize,
            height: _TopBar._buttonSize,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ── Detection info card (bottom) ───────────────────────────────────────────

class _DetectionInfoCard extends StatelessWidget {
  final _LiveResult? topResult;
  final AnimationController controller;
  const _DetectionInfoCard({required this.topResult, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = topResult;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.cardShadow],
            ),
            child: result != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.targetLocked.toUpperCase(),
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _cap(result.className),
                                  style: AppTextStyles.headlineMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(result.confidence * 100).toStringAsFixed(1)}% '
                              '${l10n.accuracyLabel}',
                              style: AppTextStyles.monoData,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProgressTrack(controller: controller),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.aimCameraHint,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final AnimationController controller;
  const _ProgressTrack({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: controller.value,
          minHeight: 4,
          backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
      ),
    );
  }
}

// ── Permission & Error screens ────────────────────────────────────────────

class _PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.no_photography_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.cameraPermissionRequired,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.cameraPermissionDesc,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────

String _cap(String s) => s.isEmpty
    ? s
    : s
          .split('_')
          .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
          .join(' ');
