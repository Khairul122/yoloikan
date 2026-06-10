import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../core/constants/app_constants.dart';
import '../models/detection_result.dart';
import '../services/ikan_repository.dart';

/// Jenis error yang dapat terjadi pada GalleryController.
/// View bertanggung jawab menerjemahkan ini ke pesan ber-locale via
/// AppLocalizations.
enum GalleryError { modelLoadFailed, noDetection, unknown }

class _ModelLoadException implements Exception {}

class GalleryController extends ChangeNotifier {
  File? _pickedImage;
  List<DetectionResult> _results = [];
  bool _isLoading = false;
  GalleryError? _error;
  String? _errorDetail;
  YOLO? _yolo;

  File? get pickedImage => _pickedImage;
  List<DetectionResult> get results => _results;
  bool get isLoading => _isLoading;
  GalleryError? get error => _error;
  String? get errorDetail => _errorDetail;
  bool get hasResults => _results.isNotEmpty;

  Future<void> _initYolo() async {
    if (_yolo != null && _yolo!.isInitialized) return;
    await _yolo?.dispose();
    _yolo = YOLO(
      modelPath: AppConstants.modelPath,
      task: AppConstants.yoloTask,
      useGpu: false, // CPU lebih stabil di semua device
    );
    final success = await _yolo!.loadModel();
    if (!success) {
      await _yolo?.dispose();
      _yolo = null;
      throw _ModelLoadException();
    }
  }

  Future<void> pickAndDetect(ImageSource source) async {
    _error = null;
    _errorDetail = null;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return;

    _pickedImage = File(file.path);
    _results = [];
    _isLoading = true;
    notifyListeners();

    try {
      await _initYolo();
      final imageBytes = await _pickedImage!.readAsBytes();
      final raw = await _yolo!.predict(
        imageBytes,
        confidenceThreshold: AppConstants.confidenceThreshold,
        iouThreshold: AppConstants.iouThreshold,
      );
      _results = await _parseResults(raw);
      if (_results.isEmpty) {
        _error = GalleryError.noDetection;
      }
    } on _ModelLoadException {
      await _yolo?.dispose();
      _yolo = null;
      _error = GalleryError.modelLoadFailed;
    } catch (e) {
      await _yolo?.dispose();
      _yolo = null;
      _error = GalleryError.unknown;
      _errorDetail = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DetectionResult>> _parseResults(Map<String, dynamic> raw) async {
    final boxes = raw['boxes'] as List<dynamic>? ?? [];
    final mapped = <DetectionResult>[];
    for (final b in boxes) {
      try {
        final result = YOLOResult.fromMap(b as Map<dynamic, dynamic>);
        if (result.confidence >= AppConstants.confidenceThreshold) {
          // Catatan: pada single-image predict (ultralytics_yolo 0.6.2),
          // map hasil deteksi tidak menyertakan key "classIndex", sehingga
          // result.classIndex selalu 0. classIndex asli dicari ulang dari
          // className lewat ikan.json.
          final species = await IkanRepository.findByName(result.className);
          final resolvedClassIndex =
              species?.id ?? AppConstants.nonFishClassIndex;

          // Model tidak punya kelas "Non Ikan" sendiri — confidence rendah
          // sering merupakan objek non-ikan, reklasifikasi ke "Non Ikan".
          final isConfident =
              result.confidence >= AppConstants.identificationThreshold;
          mapped.add(
            DetectionResult(
              label: isConfident ? result.className : 'non_ikan',
              confidence: result.confidence,
              boundingBox: result.boundingBox,
              classIndex: isConfident
                  ? resolvedClassIndex
                  : AppConstants.nonFishClassIndex,
            ),
          );
        }
      } catch (_) {}
    }
    mapped.sort((a, b) => b.confidence.compareTo(a.confidence));
    return mapped.take(1).toList();
  }

  void reset() {
    _pickedImage = null;
    _results = [];
    _error = null;
    _errorDetail = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _yolo?.dispose();
    super.dispose();
  }
}
