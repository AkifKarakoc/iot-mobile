import 'package:equatable/equatable.dart';

class DetectionResult extends Equatable {
  final int classId;
  final String className;
  final double confidence;
  final double x; // Bounding box center x
  final double y; // Bounding box center y
  final double width; // Bounding box width
  final double height; // Bounding box height

  const DetectionResult({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [
        classId,
        className,
        confidence,
        x,
        y,
        width,
        height,
      ];

  @override
  String toString() {
    return 'DetectionResult(className: $className, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
