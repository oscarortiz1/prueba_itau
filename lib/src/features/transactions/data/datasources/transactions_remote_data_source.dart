import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> fetchTransactions({required String token});

  Future<TransactionModel> createTransaction({
    required String token,
    required TransactionCreatePayload payload,
  });

  Future<TransactionModel> updateTransaction({
    required String token,
    required String id,
    required TransactionUpdatePayload payload,
  });

  Future<void> deleteTransaction({
    required String token,
    required String id,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  TransactionsRemoteDataSourceImpl({required this.client, required this.baseUrl});

  final http.Client client;
  final String baseUrl;

  Uri _buildUri(String path) => Uri.parse('$baseUrl/$path');

  Map<String, String> _headers(String token) => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      };

  @override
  Future<List<TransactionModel>> fetchTransactions({required String token}) async {
    final uri = _buildUri('transactions');

    try {
      final response = await client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = _decodeJson(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(TransactionModel.fromJson)
              .toList();
        }
        throw AppException('Formato de respuesta invalido.');
      }

      throw AppException(_extractMessage(response.body));
      } on SocketException {
        throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
      } on TimeoutException {
        throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    } on FormatException {
      throw AppException('Formato de respuesta invalido.');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required String token,
    required TransactionCreatePayload payload,
  }) async {
    final uri = _buildUri('transactions');
    final body = jsonEncode({
      'type': payload.type.value,
      'title': payload.title,
      'amount': payload.amount,
      'category': payload.category,
      'occurredAt': payload.occurredAt.toUtc().toIso8601String(),
    });

    final response = await _postOrPatch(
      request: () => client.post(uri, headers: _headers(token), body: body),
    );

    final decoded = _decodeJson(response.body);
    if (decoded is Map<String, dynamic>) {
      return TransactionModel.fromJson(decoded);
    }
    throw AppException('Formato de respuesta invalido.');
  }

  @override
  Future<TransactionModel> updateTransaction({
    required String token,
    required String id,
    required TransactionUpdatePayload payload,
  }) async {
    final uri = _buildUri('transactions/$id');
    final Map<String, dynamic> body = {};
    if (payload.type != null) {
      body['type'] = payload.type!.value;
    }
    if (payload.title != null) {
      body['title'] = payload.title;
    }
    if (payload.amount != null) {
      body['amount'] = payload.amount;
    }
    if (payload.category != null) {
      body['category'] = payload.category;
    }
    if (payload.occurredAt != null) {
      body['occurredAt'] = payload.occurredAt!.toUtc().toIso8601String();
    }

    final response = await _postOrPatch(
      request: () => client.patch(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );

    final decoded = _decodeJson(response.body);
    if (decoded is Map<String, dynamic>) {
      return TransactionModel.fromJson(decoded);
    }
    throw AppException('Formato de respuesta invalido.');
  }

  @override
  Future<void> deleteTransaction({required String token, required String id}) async {
    final uri = _buildUri('transactions/$id');

    try {
      final response = await client
          .delete(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw AppException(_extractMessage(response.body));
      } on SocketException {
        throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
      } on TimeoutException {
        throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  Future<http.Response> _postOrPatch({required Future<http.Response> Function() request}) async {
    try {
      final response = await request().timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw AppException(_extractMessage(response.body));
      } on SocketException {
        throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
      } on TimeoutException {
        throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  Object _decodeJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      throw AppException('No se pudo interpretar la respuesta del servidor.');
    }
  }

  String _extractMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          return message;
        }
        if (message is List) {
          return message.join(', ');
        }
      }
    } catch (_) {
    }
    return 'Ocurrio un error. Intenta nuevamente.';
  }
}
