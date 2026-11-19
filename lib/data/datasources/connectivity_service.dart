import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@injectable
class ConnectivityService {
  final Connectivity _connectivity;
  StreamController<bool>? _connectionStatusController;

  ConnectivityService(this._connectivity);

  /// Checks if device is currently connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnectedSingle(result);
    } catch (e) {
      return false;
    }
  }

  /// Helper to check if ConnectivityResult indicates connection
  bool _isConnectedSingle(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  /// Stream of connection status changes
  Stream<bool> get connectionStatusStream {
    _connectionStatusController ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _connectionStatusController!.stream;
  }

  void _startListening() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isConnected = _isConnectedSingle(result);
      _connectionStatusController?.add(isConnected);
    });
  }

  void _stopListening() {
    // Cleanup if needed
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}
