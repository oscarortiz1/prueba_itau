import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser extends UseCase<AuthUser, RegisterParams> {
  RegisterUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(RegisterParams params) {
    return _repository.register(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  const RegisterParams({required this.email, required this.password});

  final String email;
  final String password;
}
