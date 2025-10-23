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
            .map(
              (events) => events.any((status) => status != ConnectivityResult.none),
            )
            .distinct();

  final Connectivity _connectivity;
  final Stream<bool> _statusStream;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((status) => status != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onStatusChange => _statusStream;
}
