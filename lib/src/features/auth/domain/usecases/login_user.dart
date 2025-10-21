import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUser extends UseCase<AuthUser, LoginParams> {
  LoginUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}
