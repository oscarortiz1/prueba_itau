import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.email});

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(email: user.email);
  }

  AuthUser toEntity() => AuthUser(email: email);
}
