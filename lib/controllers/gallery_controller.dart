import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';
import '../models/detection_result.dart';
import '../services/ikan_repository.dart';

/// Jenis error yang dapat terjadi pada GalleryController.
/// View bertanggung jawab menerjemahkan ini ke pesan ber-locale via
/// AppLocalizations.
enum GalleryError { modelLoadFailed, noDetection, unknown }

class _ModelLoadException implements Exception {}

/// Hasil decode + koreksi orientasi EXIF, dihitung di isolate terpisah
/// (lihat [_bakeOrientation]) agar tidak memblokir main thread untuk foto
/// resolusi besar dari kamera HP.
typedef _OrientedImage = ({Uint8List bytes, int width, int height});

_OrientedImage _bakeOrientation(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) {
    throw Exception('Gagal membaca gambar');
  }
  final oriented = img.bakeOrientation(decoded);
  return (
    bytes: Uint8List.fromList(img.encodeJpg(oriented)),
    width: oriented.width,
    height: oriented.height,
  );
}

class GalleryController extends ChangeNotifier {
  File? _pickedImage;
  List<DetectionResult> _results = [];
  bool _isLoading = false;
  GalleryError? _error;
  String? _errorDetail;
  FlutterVision? _vision;
  bool _modelLoaded = false;

  File? get pickedImage => _pickedImage;
  List<DetectionResult> get results => _results;
  bool get isLoading => _isLoading;
  GalleryError? get error => _error;
  String? get errorDetail => _errorDetail;
  bool get hasResults => _results.isNotEmpty;

  Future<void> _initYolo() async {
    if (_modelLoaded && _vision != null) return;
    _vision = FlutterVision();
    try {
      await _vision!.loadYoloModel(
        modelPath: AppConstants.modelPath,
        labels: AppConstants.labelsPath,
        modelVersion: AppConstants.yoloModelVersion,
        quantization: false,
        numThreads: 2,
        useGpu: false,
        isAsset: true,
      );
    } catch (_) {
      _vision = null;
      _modelLoaded = false;
      throw _ModelLoadException();
    }
    _modelLoaded = true;
  }

  Future<void> pickAndDetect(ImageSource source) async {
    // Cegah pemanggilan bersamaan (mis. tap FAB dua kali cepat).
    if (_isLoading) return;

    _error = null;
    _errorDetail = null;
    _isLoading = true;
    notifyListeners();

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (file == null) return;

      _pickedImage = File(file.path);
      _results = [];

      await _initYolo();
      final rawFileBytes = await _pickedImage!.readAsBytes();

      // BitmapFactory.decodeByteArray (dipakai plugin native) mengabaikan
      // EXIF orientation, jadi foto potret dari kamera HP terbaca miring
      // oleh model — menyebabkan confidence nyaris nol untuk semua kelas.
      // Koreksi dilakukan di sisi Dart lewat compute() (isolate terpisah)
      // agar decode+encode gambar besar tidak memblokir main thread
      // (blocking di sini sempat menyebabkan ANR).
      final oriented = await compute(_bakeOrientation, rawFileBytes);

      final raw = await _vision!.yoloOnImage(
        bytesList: oriented.bytes,
        imageHeight: oriented.height,
        imageWidth: oriented.width,
        iouThreshold: AppConstants.iouThreshold,
        // flutter_vision (parser yolov8) memfilter kotak lewat
        // classThreshold, bukan confThreshold — set keduanya sama.
        confThreshold: AppConstants.confidenceThreshold,
        classThreshold: AppConstants.confidenceThreshold,
      );
      _results = await _parseResults(raw);
      if (_results.isEmpty) {
        _error = GalleryError.noDetection;
      }
    } on _ModelLoadException {
      await _vision?.closeYoloModel();
      _vision = null;
      _modelLoaded = false;
      _error = GalleryError.modelLoadFailed;
    } catch (e) {
      await _vision?.closeYoloModel();
      _vision = null;
      _modelLoaded = false;
      _error = GalleryError.unknown;
      _errorDetail = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DetectionResult>> _parseResults(
    List<Map<String, dynamic>> raw,
  ) async {
    final mapped = <DetectionResult>[];
    for (final r in raw) {
      try {
        final box = (r['box'] as List).cast<num>();
        final confidence = box[4].toDouble();
        final className = r['tag'] as String;

        // Model tidak punya kelas "Non Ikan" sendiri — confidence rendah
        // sering merupakan objek non-ikan, reklasifikasi ke "Non Ikan".
        final isConfident = confidence >= AppConstants.identificationThreshold;
        final species = await IkanRepository.findByName(className);
        final resolvedClassIndex = species?.id ?? AppConstants.nonFishClassIndex;

        mapped.add(
          DetectionResult(
            label: isConfident ? className : 'non_ikan',
            confidence: confidence,
            boundingBox: Rect.fromLTRB(
              box[0].toDouble(),
              box[1].toDouble(),
              box[2].toDouble(),
              box[3].toDouble(),
            ),
            classIndex: isConfident
                ? resolvedClassIndex
                : AppConstants.nonFishClassIndex,
          ),
        );
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
    _vision?.closeYoloModel();
    super.dispose();
  }
}
