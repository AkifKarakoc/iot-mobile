import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/waste_analysis.dart';
import '../../domain/repositories/waste_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/esp32_camera_service.dart';
import '../datasources/object_detection_service.dart';
import '../datasources/gemini_advice_service.dart';

@Injectable(as: WasteRepository)
class WasteRepositoryImpl implements WasteRepository {
  final Esp32CameraService _cameraService;
  final ObjectDetectionService _detectionService;
  final GeminiAdviceService _adviceService;

  WasteRepositoryImpl(
    this._cameraService,
    this._detectionService,
    this._adviceService,
  );

  @override
  Future<Either<Failure, WasteAnalysis>> analyzeWaste() async {
    try {
      // STEP 1: Capture image from ESP32-CAM
      print('📸 Step 1: Capturing image from ESP32-CAM...');
      final imageBytes = await _cameraService.captureImage();
      print('✅ Image captured successfully');

      // STEP 2: Run AI detection
      print('🤖 Step 2: Running AI inference...');
      final detections = await _detectionService.detectObjects(imageBytes);
      print('✅ Detected ${detections.length} objects');

      if (detections.isEmpty) {
        // No objects detected
        return Right(WasteAnalysis(
          capturedImage: imageBytes,
          detections: [],
          advice: null,
          timestamp: DateTime.now(),
        ));
      }

      // STEP 3: Get composting advice for primary detection
      print('💡 Step 3: Fetching composting advice...');
      final primaryDetection = detections.first;
      final advice = await _adviceService.getAdvice(primaryDetection.className);
      print('✅ Advice received (Source: ${advice.sourceLabel})');

      return Right(WasteAnalysis(
        capturedImage: imageBytes,
        detections: detections,
        advice: advice,
        timestamp: DateTime.now(),
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Analiz hatası: $e'));
    }
  }

  @override
  Future<Either<Failure, WasteAnalysis>> analyzeLocalImage(
      Uint8List imageBytes) async {
    try {
      // STEP 1: Image already provided (from camera/gallery)
      print('📱 Step 1: Using local image...');
      print('✅ Image ready');

      // STEP 2: Run AI detection
      print('🤖 Step 2: Running AI inference...');
      final detections = await _detectionService.detectObjects(imageBytes);
      print('✅ Detected ${detections.length} objects');

      if (detections.isEmpty) {
        // No objects detected
        return Right(WasteAnalysis(
          capturedImage: imageBytes,
          detections: [],
          advice: null,
          timestamp: DateTime.now(),
        ));
      }

      // STEP 3: Get composting advice for primary detection
      print('💡 Step 3: Fetching composting advice...');
      final primaryDetection = detections.first;
      final advice = await _adviceService.getAdvice(primaryDetection.className);
      print('✅ Advice received (Source: ${advice.sourceLabel})');

      return Right(WasteAnalysis(
        capturedImage: imageBytes,
        detections: detections,
        advice: advice,
        timestamp: DateTime.now(),
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Analiz hatası: $e'));
    }
  }

  @override
  Future<bool> isCameraConnected() async {
    return await _cameraService.isConnected();
  }

  @override
  Future<String> getEsp32IpAddress() async {
    return await _cameraService.getIpAddress();
  }

  @override
  Future<void> setEsp32IpAddress(String ipAddress) async {
    await _cameraService.setIpAddress(ipAddress);
  }
}
