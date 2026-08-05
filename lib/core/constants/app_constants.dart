class AppConstants {
  AppConstants._();

  static const String appName = 'FishScan';
  static const String appTagline = 'Klasifikasi Jenis Ikan';
  static const String appVersion = '1.0.1';

  static const String modelPath = 'assets/models/best.tflite';
  static const String labelsPath = 'assets/models/labels.txt';

  // Kepala deteksi model (single output tensor 1x(4+nc)x8400) kompatibel
  // dengan parser "yolov8" flutter_vision terlepas dari versi arsitektur
  // training (v8/v11 memakai format output yang sama).
  static const String yoloModelVersion = 'yolov8';

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
  static const String loginRoute = '/login';
}
