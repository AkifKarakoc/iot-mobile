import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class Esp32CameraService {
  final Dio _dio;
  final SharedPreferences _prefs;

  Esp32CameraService(this._dio, this._prefs) {
    _dio.options = BaseOptions(
      connectTimeout: Duration(milliseconds: AppConstants.cameraTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.cameraTimeout),
    );
  }

  /// Gets the configured ESP32-CAM IP address
  Future<String> getIpAddress() async {
    return _prefs.getString(AppConstants.esp32IpKey) ??
        AppConstants.defaultEsp32Ip;
  }

  /// Sets the ESP32-CAM IP address
  Future<void> setIpAddress(String ipAddress) async {
    await _prefs.setString(AppConstants.esp32IpKey, ipAddress);
  }

  /// Captures a high-resolution image from ESP32-CAM
  Future<Uint8List> captureImage() async {
    try {
      final ipAddress = await getIpAddress();
      final url = 'http://$ipAddress${AppConstants.captureEndpoint}';

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'image/jpeg'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data);
      } else {
        throw const CameraFailure('Görüntü alınamadı');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const TimeoutFailure('ESP32-CAM bağlantı zaman aşımı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const CameraFailure(
            'ESP32-CAM\'e bağlanılamıyor. IP adresini kontrol edin.');
      } else {
        throw CameraFailure('Kamera hatası: ${e.message}');
      }
    } catch (e) {
      throw CameraFailure('Beklenmeyen kamera hatası: $e');
    }
  }

  /// Checks if ESP32-CAM is reachable
  Future<bool> isConnected() async {
    try {
      final ipAddress = await getIpAddress();
      final url = 'http://$ipAddress/';

      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      return false;
    }
  }

  /// Gets the stream URL for live preview
  String getStreamUrl() {
    final ipAddress = _prefs.getString(AppConstants.esp32IpKey) ??
        AppConstants.defaultEsp32Ip;
    return 'http://$ipAddress${AppConstants.streamEndpoint}';
  }
}
