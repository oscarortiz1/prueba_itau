import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum TransactionsRealtimeMessageType { created, updated, deleted }

class TransactionsRealtimeMessage {
  const TransactionsRealtimeMessage({
    required this.type,
    this.payload,
  });

  final TransactionsRealtimeMessageType type;
  final Map<String, dynamic>? payload;
}

class TransactionsRealtimeDataSource {
  TransactionsRealtimeDataSource({required this.baseUrl});

  final String baseUrl;

  final _controller = StreamController<TransactionsRealtimeMessage>.broadcast();

  io.Socket? _socket;
  String? _currentToken;

  Stream<TransactionsRealtimeMessage> get messages => _controller.stream;

  void connect(String token) {
    if (token.isEmpty) {
      return;
    }

    if (_currentToken == token && _socket != null && _socket!.connected) {
      return;
    }

    _currentToken = token;
    _recreateSocket(token);
  }

  void disconnect() {
    _currentToken = null;
    _disposeSocket();
  }

  void dispose() {
    _disposeSocket();
    _controller.close();
  }

  void _recreateSocket(String token) {
    _disposeSocket();

    final url = '$baseUrl/transactions';
    try {
      final socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .setAuth({'token': token})
            .build(),
      );

      socket.onConnect((_) {
      });

      void handleError(Object? error) {
        if (!_controller.isClosed) {
          _controller.addError(error ?? 'socket_error');
        }
      }

      socket
        ..onError(handleError)
        ..onConnectError(handleError)
        ..onDisconnect((_) {
        });

      socket.on('transaction.created', (data) {
        final payload = _asJson(data);
        if (payload != null) {
          _controller.add(TransactionsRealtimeMessage(
            type: TransactionsRealtimeMessageType.created,
            payload: payload,
          ));
        }
      });

      socket.on('transaction.updated', (data) {
        final payload = _asJson(data);
        if (payload != null) {
          _controller.add(TransactionsRealtimeMessage(
            type: TransactionsRealtimeMessageType.updated,
            payload: payload,
          ));
        }
      });

      socket.on('transaction.deleted', (data) {
        final payload = _asJson(data);
        _controller.add(TransactionsRealtimeMessage(
          type: TransactionsRealtimeMessageType.deleted,
          payload: payload,
        ));
      });

      socket.connect();
      _socket = socket;
    } on Object catch (error, stackTrace) {
      if (!_controller.isClosed) {
        _controller.addError(error, stackTrace);
      }
      _disposeSocket();
    }
  }

  void _disposeSocket() {
    _socket?.dispose();
    _socket = null;
  }

  Map<String, dynamic>? _asJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
