import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;

  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity)
      : _statusStream = _connectivity
            .onConnectivityChanged
            .map((event) => event != ConnectivityResult.none)
            .distinct();

  final Connectivity _connectivity;
  final Stream<bool> _statusStream;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get onStatusChange => _statusStream;
}
