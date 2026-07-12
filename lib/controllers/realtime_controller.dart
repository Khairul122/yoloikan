import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../core/constants/app_constants.dart';

class RealtimeController extends ChangeNotifier {
  YOLOViewController? _viewController;
  String? _error;

  YOLOViewController get viewController {
    if (_viewController == null) {
      _viewController = YOLOViewController();
      // Hanya tampilkan 1 bounding box dengan confidence tertinggi
      _viewController!.setNumItemsThreshold(1);
    }
    return _viewController!;
  }

  String get modelPath => AppConstants.modelPath;
  String? get error => _error;

  void onViewError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _viewController?.dispose();
    _viewController = null;
    super.dispose();
  }
}
