import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'FishScan';
  static const String appTagline = 'Klasifikasi Jenis Ikan';
  static const String appVersion = '1.0.0';

  static const String modelPath = 'assets/models/best_float32.tflite';

  // task bisa null — library akan baca dari metadata model secara otomatis
  static const YOLOTask yoloTask = YOLOTask.detect;

  static const double confidenceThreshold = 0.40;
  static const double identificationThreshold = 0.65;
  static const double iouThreshold = 0.45;

  /// classIndex pada ikan.json untuk kategori "Non Ikan" — dipakai untuk
  /// mereklasifikasi hasil deteksi dengan confidence < identificationThreshold
  /// (model tidak punya kelas non-ikan sendiri).
  static const int nonFishClassIndex = 6;

  static const String galleryRoute = '/gallery';
  static const String realtimeRoute = '/realtime';
  static const String detailRoute = '/detail';
}
