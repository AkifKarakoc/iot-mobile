import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/waste_analysis.dart';
import '../../domain/usecases/analyze_waste_usecase.dart';
import '../../data/datasources/connectivity_service.dart';
import '../../data/datasources/esp32_camera_service.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/image_picker_service.dart';
import '../../domain/repositories/waste_repository.dart';

// Use case provider
final analyzeWasteUseCaseProvider = Provider<AnalyzeWasteUseCase>((ref) {
  return getIt<AnalyzeWasteUseCase>();
});

// Repository provider
final wasteRepositoryProvider = Provider((ref) {
  return getIt<WasteRepository>();
});

// Image picker service provider
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return getIt<ImagePickerService>();
});

// Connectivity service provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return getIt<ConnectivityService>();
});

// Camera service provider
final cameraServiceProvider = Provider<Esp32CameraService>((ref) {
  return getIt<Esp32CameraService>();
});

// Internet connection status stream
final internetStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStatusStream;
});

// ESP32 connection status stream
final esp32StatusProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(cameraServiceProvider);

  while (true) {
    yield await service.isConnected();
    await Future.delayed(const Duration(seconds: 5)); // Check every 5 seconds
  }
});

// Analysis state
enum AnalysisStatus { idle, loading, success, error }

class AnalysisState {
  final AnalysisStatus status;
  final WasteAnalysis? analysis;
  final String? errorMessage;

  AnalysisState({
    required this.status,
    this.analysis,
    this.errorMessage,
  });

  factory AnalysisState.idle() => AnalysisState(status: AnalysisStatus.idle);

  factory AnalysisState.loading() =>
      AnalysisState(status: AnalysisStatus.loading);

  factory AnalysisState.success(WasteAnalysis analysis) => AnalysisState(
        status: AnalysisStatus.success,
        analysis: analysis,
      );

  factory AnalysisState.error(String message) => AnalysisState(
        status: AnalysisStatus.error,
        errorMessage: message,
      );
}

// Analysis state notifier
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AnalyzeWasteUseCase _analyzeWasteUseCase;
  final WasteRepository _repository;
  final ImagePickerService _imagePickerService;

  AnalysisNotifier(
    this._analyzeWasteUseCase,
    this._repository,
    this._imagePickerService,
  ) : super(AnalysisState.idle());

  /// Analyzes waste from ESP32-CAM
  Future<void> analyzeWaste() async {
    state = AnalysisState.loading();

    final result = await _analyzeWasteUseCase();

    result.fold(
      (failure) => state = AnalysisState.error(failure.message),
      (analysis) => state = AnalysisState.success(analysis),
    );
  }

  /// Analyzes image from phone camera
  Future<void> analyzeFromCamera() async {
    try {
      // Pick image from camera
      final imageBytes = await _imagePickerService.pickFromCamera();

      // Cancelled by the user: stay on the dashboard without any message.
      if (imageBytes == null) {
        state = AnalysisState.idle();
        return;
      }

      // Show the loading state only once there is an image to analyze
      state = AnalysisState.loading();

      // Analyze the image
      final result = await _repository.analyzeLocalImage(imageBytes);

      result.fold(
        (failure) => state = AnalysisState.error(failure.message),
        (analysis) => state = AnalysisState.success(analysis),
      );
    } on Failure catch (failure) {
      state = AnalysisState.error(failure.message);
    } catch (e) {
      state = AnalysisState.error('Kamera hatası: $e');
    }
  }

  /// Analyzes image from gallery
  Future<void> analyzeFromGallery() async {
    try {
      // Pick image from gallery
      final imageBytes = await _imagePickerService.pickFromGallery();

      // Cancelled by the user: stay on the dashboard without any message.
      if (imageBytes == null) {
        state = AnalysisState.idle();
        return;
      }

      // Show the loading state only once there is an image to analyze
      state = AnalysisState.loading();

      // Analyze the image
      final result = await _repository.analyzeLocalImage(imageBytes);

      result.fold(
        (failure) => state = AnalysisState.error(failure.message),
        (analysis) => state = AnalysisState.success(analysis),
      );
    } on Failure catch (failure) {
      state = AnalysisState.error(failure.message);
    } catch (e) {
      state = AnalysisState.error('Galeri hatası: $e');
    }
  }

  void reset() {
    state = AnalysisState.idle();
  }
}

// Analysis state provider
final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final useCase = ref.watch(analyzeWasteUseCaseProvider);
  final repository = ref.watch(wasteRepositoryProvider);
  final imagePickerService = ref.watch(imagePickerServiceProvider);
  return AnalysisNotifier(useCase, repository, imagePickerService);
});
