class HistoryItem {
  final String id;
  final int classIndex;
  final String className;
  final double confidence;
  final String? photoPath;
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.classIndex,
    required this.className,
    required this.confidence,
    required this.timestamp,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classIndex': classIndex,
    'className': className,
    'confidence': confidence,
    'photoPath': photoPath,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json['id'] as String,
    classIndex: json['classIndex'] as int,
    className: json['className'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    photoPath: json['photoPath'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
