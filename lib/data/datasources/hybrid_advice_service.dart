import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/compost_advice.dart';
import '../models/compost_advice_model.dart';
import 'connectivity_service.dart';

@injectable
class HybridAdviceService {
  final Dio _dio;
  final ConnectivityService _connectivityService;

  HybridAdviceService(this._dio, this._connectivityService) {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseApiUrl,
      connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
    );
  }

  /// Gets composting advice using hybrid approach:
  /// SCENARIO A (Online - Primary): Try API first
  /// SCENARIO B (Offline - Fallback): Use local JSON if API fails or offline
  Future<CompostAdvice> getAdvice(String wasteType) async {
    // Check internet connectivity
    final isOnline = await _connectivityService.isConnected();

    if (isOnline) {
      // SCENARIO A: Try API first
      try {
        print('🌐 Attempting to fetch advice from API for: $wasteType');
        final advice = await _fetchFromApi(wasteType);
        print('✅ API response received');
        return advice;
      } catch (e) {
        print('⚠️ API failed: $e. Falling back to local JSON...');
        // Fallback to local JSON
        return await _fetchFromLocalJson(wasteType);
      }
    } else {
      // SCENARIO B: Offline mode - use local JSON directly
      print('📴 Offline mode detected. Using local JSON...');
      return await _fetchFromLocalJson(wasteType);
    }
  }

  /// Fetches advice from backend API
  Future<CompostAdvice> _fetchFromApi(String wasteType) async {
    try {
      final response = await _dio.get(
        AppConstants.adviceEndpoint,
        queryParameters: {'wasteType': wasteType},
      );

      if (response.statusCode == 200 && response.data != null) {
        final model = CompostAdviceModel.fromJson(response.data);
        return model.toEntity(isFromApi: true);
      } else {
        throw ServerFailure('API yanıt vermedi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutFailure('API zaman aşımı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('API bağlantı hatası');
      } else {
        throw ServerFailure('API hatası: ${e.message}');
      }
    }
  }

  /// Fetches advice from local JSON file
  Future<CompostAdvice> _fetchFromLocalJson(String wasteType) async {
    try {
      // Load JSON from assets
      final jsonString =
          await rootBundle.loadString(AppConstants.wasteGuideJsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Find matching waste type (case-insensitive)
      final normalizedWasteType = wasteType.toLowerCase().trim();
      final adviceData = jsonData[normalizedWasteType];

      if (adviceData == null) {
        // Return default advice if waste type not found
        return CompostAdvice(
          wasteType: wasteType,
          isCompostable: false,
          tips: ['Bu atık türü için bilgi bulunamadı.'],
          suitableAnimals: [],
          additionalInfo: 'Lütfen internet bağlantınızı kontrol edin.',
          isFromApi: false,
        );
      }

      final model = CompostAdviceModel.fromJson(adviceData);
      return model.toEntity(isFromApi: false);
    } catch (e) {
      throw CacheFailure('Yerel veri okunamadı: $e');
    }
  }

  /// Preloads local JSON for faster offline access (optional optimization)
  Future<void> preloadLocalData() async {
    try {
      await rootBundle.loadString(AppConstants.wasteGuideJsonPath);
      print('✅ Local waste guide preloaded');
    } catch (e) {
      print('⚠️ Failed to preload local data: $e');
    }
  }
}
