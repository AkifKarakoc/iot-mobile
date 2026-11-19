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

  // Letterbox geometry of the last preprocessed image, used to map boxes
  // back to the original image.
  double _scale = 1.0;
  int _padX = 0;
  int _padY = 0;
  int _scaledWidth = AppConstants.inputImageSize;
  int _scaledHeight = AppConstants.inputImageSize;

  /// Preprocesses image for YOLOv11 input.
  ///
  /// Uses letterboxing like Ultralytics training: the image is scaled to fit
  /// 640x640 without changing its aspect ratio and padded with gray (114).
  /// Stretching wide photos instead distorts objects and hurts detection.
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final size = AppConstants.inputImageSize;
    _scale = size / (image.width > image.height ? image.width : image.height);
    _scaledWidth = (image.width * _scale).round();
    _scaledHeight = (image.height * _scale).round();
    _padX = (size - _scaledWidth) ~/ 2;
    _padY = (size - _scaledHeight) ~/ 2;

    final scaled = img.copyResize(
      image,
      width: _scaledWidth,
      height: _scaledHeight,
    );
    final resized = img.Image(width: size, height: size);
    img.fill(resized, color: img.ColorRgb8(114, 114, 114));
    img.compositeImage(resized, scaled, dstX: _padX, dstY: _padY);

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

  /// Post-processes YOLOv11 output.
  ///
  /// The bundled model was exported with NMS built in, so its output is
  /// [1, 300, 6]: each row is (x1, y1, x2, y2, confidence, classId).
  /// Raw exports without NMS ([1, 4 + numClasses, 8400]) are still supported.
  List<DetectionResult> _postprocessOutput(
    List<List<List<double>>> output,
    int originalWidth,
    int originalHeight,
  ) {
    if (output[0].isNotEmpty && output[0][0].length == 6) {
      return _postprocessNmsOutput(output);
    }

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

  /// Parses an NMS-exported output ([1, N, 6] rows of x1, y1, x2, y2, conf, cls).
  /// Boxes are converted to normalized center/width/height to match
  /// [DetectionResult].
  List<DetectionResult> _postprocessNmsOutput(List<List<List<double>>> output) {
    final detections = <DetectionResult>[];
    final inputSize = AppConstants.inputImageSize.toDouble();

    for (final row in output[0]) {
      final confidence = row[4];
      if (confidence < AppConstants.confidenceThreshold) continue;

      var x1 = row[0], y1 = row[1], x2 = row[2], y2 = row[3];
      // Some exports return pixel coordinates; normalize them to 0..1.
      if (x2 > 1.5 || y2 > 1.5) {
        x1 /= inputSize;
        y1 /= inputSize;
        x2 /= inputSize;
        y2 /= inputSize;
      }

      // Undo the letterbox: from 640x640 canvas to the original image (0..1).
      double toX(double v) =>
          ((v * inputSize - _padX) / _scaledWidth).clamp(0.0, 1.0);
      double toY(double v) =>
          ((v * inputSize - _padY) / _scaledHeight).clamp(0.0, 1.0);
      x1 = toX(x1);
      x2 = toX(x2);
      y1 = toY(y1);
      y2 = toY(y2);

      final classId = row[5].round();
      detections.add(DetectionResult(
        classId: classId,
        className: AppConstants.wasteClassNames[classId] ?? 'unknown',
        confidence: confidence,
        x: (x1 + x2) / 2,
        y: (y1 + y2) / 2,
        width: x2 - x1,
        height: y2 - y1,
      ));
    }

    // The model already applied NMS; results are sorted by confidence.
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detections;
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
