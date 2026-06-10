import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final Rect? boundingBox;
  final int classIndex;

  const DetectionResult({
    required this.label,
    required this.confidence,
    this.boundingBox,
    this.classIndex = -1,
  });

  /// True jika confidence cukup tinggi untuk dianggap identifikasi ikan yang
  /// valid (lihat AppConstants.identificationThreshold).
  bool get isConfidentFish =>
      confidence >= AppConstants.identificationThreshold;

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  String get displayLabel {
    if (label.isEmpty) return 'Unknown';
    return label
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  String toString() =>
      'DetectionResult(label: $label, confidence: $confidence)';
}
