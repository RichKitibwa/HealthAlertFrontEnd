// Network connectivity monitoring service
// Monitors internet connection and notifies app of changes

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _onlineController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check current status
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      if (wasOnline != _isOnline) {
        _onlineController.add(_isOnline);
      }
    });
  }

  /// Check if we currently have network connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    return _isOnline;
  }

  void dispose() {
    _subscription?.cancel();
    _onlineController.close();
  }
}
