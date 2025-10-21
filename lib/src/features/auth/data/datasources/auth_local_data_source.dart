import '../../../../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthUserModel> login({required String email, required String password});

  Future<AuthUserModel> register({
    required String email,
    required String password,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl();

  final Map<String, String> _users = <String, String>{};

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final storedPassword = _users[email];
    if (storedPassword == null || storedPassword != password) {
      throw AppException('Credenciales invalidas.');
    }

    return AuthUserModel(email: email);
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    if (_users.containsKey(email)) {
      throw AppException('El usuario ya existe.');
    }

    _users[email] = password;
    return AuthUserModel(email: email);
  }
}
