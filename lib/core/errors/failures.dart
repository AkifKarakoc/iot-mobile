import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Ağ bağlantısı hatası'])
      : super(message);
}

class CameraFailure extends Failure {
  const CameraFailure([String message = 'ESP32-CAM bağlantı hatası'])
      : super(message);
}

class AIFailure extends Failure {
  const AIFailure([String message = 'AI analiz hatası']) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Sunucu hatası']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Önbellek hatası']) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'İstek zaman aşımına uğradı'])
      : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Bilinmeyen hata']) : super(message);
}
