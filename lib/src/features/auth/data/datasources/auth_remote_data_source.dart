import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login({required String email, required String password});

  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String confirmPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  Uri _buildUri(String path) => Uri.parse('$baseUrl/$path');

  Map<String, String> get _headers => const {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      uri: _buildUri('auth/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw AppException('Respuesta inesperada del servidor.');
    }

    final token = data['accessToken'] as String?;
    return AuthUserModel.fromJson(userJson, token: token);
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _post(
      uri: _buildUri('auth/register'),
      body: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw AppException('Respuesta inesperada del servidor.');
    }

    return AuthUserModel.fromJson(userJson);
  }

  Future<Map<String, dynamic>> _post({
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.postUri(
        uri,
        data: body,
        options: Options(headers: _headers),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }

      throw AppException('Formato de respuesta invalido.');
    } on DioException catch (error) {
      throw AppException(_mapDioError(error));
    } on SocketException {
      throw AppException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw AppException('La solicitud tardo demasiado. Intenta nuevamente.');
    }
  }

  String _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'La solicitud tardo demasiado. Intenta nuevamente.';
    }

    if (error.type == DioExceptionType.badResponse) {
      final data = error.response?.data;
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

    if (error.error is SocketException) {
      return 'Sin conexion con el servidor. Verifica tu red.';
    }

    return 'Ocurrio un error. Intenta nuevamente.';
  }
}
