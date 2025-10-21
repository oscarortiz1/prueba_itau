import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _localDataSource.login(
      email: email,
      password: password,
    );

    return user.toEntity();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final user = await _localDataSource.register(
      email: email,
      password: password,
    );

    return user.toEntity();
  }
}
