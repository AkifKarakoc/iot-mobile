import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../entities/waste_analysis.dart';
import '../../core/errors/failures.dart';

abstract class WasteRepository {
  /// Performs complete waste analysis:
  /// 1. Captures image from ESP32-CAM
  /// 2. Runs AI detection
  /// 3. Fetches composting advice (hybrid: API or local)
  Future<Either<Failure, WasteAnalysis>> analyzeWaste();

  /// Analyzes image from local source (camera/gallery):
  /// 1. Uses provided image bytes
  /// 2. Runs AI detection
  /// 3. Fetches composting advice (hybrid: API or local)
  Future<Either<Failure, WasteAnalysis>> analyzeLocalImage(Uint8List imageBytes);

  /// Checks if ESP32-CAM is connected
  Future<bool> isCameraConnected();

  /// Gets current ESP32-CAM IP address
  Future<String> getEsp32IpAddress();

  /// Sets ESP32-CAM IP address
  Future<void> setEsp32IpAddress(String ipAddress);
}
