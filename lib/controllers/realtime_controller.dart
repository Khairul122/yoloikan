import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import '../core/constants/app_constants.dart';

class RealtimeController extends ChangeNotifier {
  FlutterVision? _vision;
  bool _modelLoaded = false;
  String? _error;

  String? get error => _error;

  /// Memuat model sekali saja; aman dipanggil berulang kali.
  Future<FlutterVision> ensureModelLoaded() async {
    if (_modelLoaded && _vision != null) return _vision!;
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
      _modelLoaded = true;
    } catch (e) {
      _vision = null;
      _modelLoaded = false;
      rethrow;
    }
    return _vision!;
  }

  void onViewError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _vision?.closeYoloModel();
    _vision = null;
    super.dispose();
  }
}
