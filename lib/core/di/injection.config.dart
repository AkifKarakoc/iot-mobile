// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/datasources/connectivity_service.dart' as _i635;
import '../../data/datasources/esp32_camera_service.dart' as _i666;
import '../../data/datasources/gemini_advice_service.dart' as _i598;
import '../../data/datasources/hybrid_advice_service.dart' as _i185;
import '../../data/datasources/image_picker_service.dart' as _i148;
import '../../data/datasources/object_detection_service.dart' as _i16;
import '../../data/repositories/waste_repository_impl.dart' as _i208;
import '../../domain/repositories/waste_repository.dart' as _i965;
import '../../domain/usecases/analyze_waste_usecase.dart' as _i457;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i16.ObjectDetectionService>(
        () => _i16.ObjectDetectionService());
    gh.factory<_i666.Esp32CameraService>(() => _i666.Esp32CameraService(
          gh<_i361.Dio>(),
          gh<_i460.SharedPreferences>(),
        ));
    gh.factory<_i635.ConnectivityService>(
        () => _i635.ConnectivityService(gh<_i895.Connectivity>()));
    gh.factory<_i148.ImagePickerService>(
        () => _i148.ImagePickerService(gh<_i183.ImagePicker>()));
    gh.factory<_i185.HybridAdviceService>(() => _i185.HybridAdviceService(
          gh<_i361.Dio>(),
          gh<_i635.ConnectivityService>(),
        ));
    gh.factory<_i598.GeminiAdviceService>(
        () => _i598.GeminiAdviceService(gh<_i635.ConnectivityService>()));
    gh.factory<_i965.WasteRepository>(() => _i208.WasteRepositoryImpl(
          gh<_i666.Esp32CameraService>(),
          gh<_i16.ObjectDetectionService>(),
          gh<_i598.GeminiAdviceService>(),
        ));
    gh.factory<_i457.AnalyzeWasteUseCase>(
        () => _i457.AnalyzeWasteUseCase(gh<_i965.WasteRepository>()));
    return this;
  }
}
