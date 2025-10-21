import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
  AuthRemoteDataSourceImpl({required this.client, required this.baseUrl});

  final http.Client client;
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
    final response = await _post(
      uri: _buildUri('auth/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = _decodeJson(response.body) as Map<String, dynamic>;
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
    final response = await _post(
      uri: _buildUri('auth/register'),
      body: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    final data = _decodeJson(response.body) as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw AppException('Respuesta inesperada del servidor.');
    }

    return AuthUserModel.fromJson(userJson);
  }

  Future<http.Response> _post({required Uri uri, required Map<String, dynamic> body}) async {
    try {
      final response = await client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw AppException(_extractMessage(response.body));
    } on SocketException {
      throw AppException('Sin conexion con el servidor. Verifica tu red.');
    } on TimeoutException {
      throw AppException('La solicitud tardo demasiado. Intenta nuevamente.');
    } on FormatException {
      throw AppException('Formato de respuesta invalido.');
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
      // Ignored: fall back to default message.
    }
    return 'Ocurrio un error. Intenta nuevamente.';
  }
}
