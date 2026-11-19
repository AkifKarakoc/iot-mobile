import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/detection_result.dart';

@injectable
class ObjectDetectionService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initializes the TFLite model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      _isInitialized = true;
      print('✅ YOLOv11 model loaded successfully');
    } catch (e) {
      throw AIFailure('Model yüklenemedi: $e');
    }
  }

  /// Detects objects in the given image
  Future<List<DetectionResult>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const AIFailure('Görüntü decode edilemedi');
      }

      // Preprocess image
      final inputTensor = _preprocessImage(image);

      // Prepare output tensors
      // YOLOv11 output shape: [1, 84, 8400]
      // 84 = 4 (bbox) + 80 (classes) for COCO, adjust based on your model
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.filled(outputShape[2], 0.0),
        ),
      );

      // Run inference
      _interpreter!.run(inputTensor, output);

      // Post-process results
      final detections = _postprocessOutput(output, image.width, image.height);

      return detections;
    } catch (e) {
      throw AIFailure('Tespit hatası: $e');
    }
  }

  /// Preprocesses image for YOLOv11 input
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to model input size
    final resized = img.copyResize(
      image,
      width: AppConstants.inputImageSize,
      height: AppConstants.inputImageSize,
    );

    // Normalize to [0, 1]
    final input = List.generate(
      1,
      (_) => List.generate(
        AppConstants.inputImageSize,
        (y) => List.generate(
          AppConstants.inputImageSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  /// Post-processes YOLOv11 output
  List<DetectionResult> _postprocessOutput(
    List<List<List<double>>> output,
    int originalWidth,
    int originalHeight,
  ) {
    final detections = <DetectionResult>[];
    final numDetections = output[0][0].length;

    for (int i = 0; i < numDetections; i++) {
      // Extract bbox and class scores
      final x = output[0][0][i];
      final y = output[0][1][i];
      final w = output[0][2][i];
      final h = output[0][3][i];

      // Find class with highest confidence
      double maxConfidence = 0.0;
      int maxClassId = 0;

      for (int c = 4; c < output[0].length; c++) {
        final confidence = output[0][c][i];
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          maxClassId = c - 4;
        }
      }

      // Filter by confidence threshold
      if (maxConfidence >= AppConstants.confidenceThreshold) {
        final className = AppConstants.wasteClassNames[maxClassId] ?? 'unknown';

        detections.add(DetectionResult(
          classId: maxClassId,
          className: className,
          confidence: maxConfidence,
          x: x,
          y: y,
          width: w,
          height: h,
        ));
      }
    }

    // Apply Non-Maximum Suppression (NMS)
    final filteredDetections = _applyNMS(detections);

    return filteredDetections;
  }

  /// Applies Non-Maximum Suppression to remove overlapping boxes
  List<DetectionResult> _applyNMS(List<DetectionResult> detections) {
    if (detections.isEmpty) return [];

    // Sort by confidence (descending)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final selected = <DetectionResult>[];

    for (final detection in detections) {
      bool shouldKeep = true;

      for (final selectedDetection in selected) {
        final iou = _calculateIoU(detection, selectedDetection);
        if (iou > AppConstants.iouThreshold) {
          shouldKeep = false;
          break;
        }
      }

      if (shouldKeep) {
        selected.add(detection);
      }
    }

    return selected;
  }

  /// Calculates Intersection over Union (IoU) between two bounding boxes
  double _calculateIoU(DetectionResult a, DetectionResult b) {
    final x1 = (a.x - a.width / 2).clamp(0.0, 1.0);
    final y1 = (a.y - a.height / 2).clamp(0.0, 1.0);
    final x2 = (a.x + a.width / 2).clamp(0.0, 1.0);
    final y2 = (a.y + a.height / 2).clamp(0.0, 1.0);

    final x1b = (b.x - b.width / 2).clamp(0.0, 1.0);
    final y1b = (b.y - b.height / 2).clamp(0.0, 1.0);
    final x2b = (b.x + b.width / 2).clamp(0.0, 1.0);
    final y2b = (b.y + b.height / 2).clamp(0.0, 1.0);

    final intersectionX1 = x1 > x1b ? x1 : x1b;
    final intersectionY1 = y1 > y1b ? y1 : y1b;
    final intersectionX2 = x2 < x2b ? x2 : x2b;
    final intersectionY2 = y2 < y2b ? y2 : y2b;

    final intersectionArea = (intersectionX2 - intersectionX1).clamp(0.0, 1.0) *
        (intersectionY2 - intersectionY1).clamp(0.0, 1.0);

    final areaA = (x2 - x1) * (y2 - y1);
    final areaB = (x2b - x1b) * (y2b - y1b);

    final unionArea = areaA + areaB - intersectionArea;

    return unionArea > 0 ? intersectionArea / unionArea : 0.0;
  }

  /// Disposes the interpreter
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
