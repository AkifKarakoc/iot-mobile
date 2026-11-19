import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/waste_analysis.dart';
import '../repositories/waste_repository.dart';
import '../../core/errors/failures.dart';

@injectable
class AnalyzeWasteUseCase {
  final WasteRepository repository;

  AnalyzeWasteUseCase(this.repository);

  /// Executes the complete waste analysis workflow:
  /// STEP 1: Capture image from ESP32-CAM
  /// STEP 2: Run AI inference (YOLOv11)
  /// STEP 3: Get composting advice (Hybrid: API → Local fallback)
  Future<Either<Failure, WasteAnalysis>> call() async {
    return await repository.analyzeWaste();
  }
}
