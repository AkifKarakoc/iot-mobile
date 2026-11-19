import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'detection_result.dart';
import 'compost_advice.dart';

class WasteAnalysis extends Equatable {
  final Uint8List capturedImage;
  final List<DetectionResult> detections;
  final CompostAdvice? advice;
  final DateTime timestamp;

  const WasteAnalysis({
    required this.capturedImage,
    required this.detections,
    this.advice,
    required this.timestamp,
  });

  bool get hasDetections => detections.isNotEmpty;

  DetectionResult? get primaryDetection =>
      detections.isNotEmpty ? detections.first : null;

  @override
  List<Object?> get props => [
        capturedImage,
        detections,
        advice,
        timestamp,
      ];
}
