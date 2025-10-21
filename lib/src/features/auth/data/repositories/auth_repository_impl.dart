import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    return user.toEntity();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final user = await _remoteDataSource.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    return user.toEntity();
  }
}
