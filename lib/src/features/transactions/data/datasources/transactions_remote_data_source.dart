import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

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
  TransactionsRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  final Dio dio;
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
      final response = await dio.getUri(
        uri,
        options: Options(headers: _headers(token)),
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TransactionModel.fromJson)
            .toList();
      }
      throw AppException('Formato de respuesta invalido.');
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on SocketException {
      throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required String token,
    required TransactionCreatePayload payload,
  }) async {
    final uri = _buildUri('transactions');
    final payloadBody = {
      'type': payload.type.value,
      'title': payload.title,
      'amount': payload.amount,
      'category': payload.category,
      'occurredAt': payload.occurredAt.toUtc().toIso8601String(),
    };

    try {
      final response = await dio.postUri(
        uri,
        data: payloadBody,
        options: Options(headers: _headers(token)),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TransactionModel.fromJson(data);
      }
      throw AppException('Formato de respuesta invalido.');
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on SocketException {
      throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
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

    try {
      final response = await dio.patchUri(
        uri,
        data: body,
        options: Options(headers: _headers(token)),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TransactionModel.fromJson(data);
      }
      throw AppException('Formato de respuesta invalido.');
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on SocketException {
      throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  @override
  Future<void> deleteTransaction({required String token, required String id}) async {
    final uri = _buildUri('transactions/$id');

    try {
      await dio.deleteUri(
        uri,
        options: Options(headers: _headers(token)),
      );
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on SocketException {
      throw NetworkException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  AppException _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException('La solicitud tardo demasiado. Intenta nuevamente.');
    }

    if (error.error is SocketException) {
      return NetworkException('Sin conexion con el servidor. Verifica tu red.');
    }

    if (error.type == DioExceptionType.badResponse) {
      final message = _extractMessage(error.response?.data);
      return AppException(message);
    }

    return AppException('Ocurrio un error. Intenta nuevamente.');
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
      if (message is List) {
        return message.join(', ');
      }
    }
    return 'Ocurrio un error. Intenta nuevamente.';
  }
}
