import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.email,
    this.id,
    this.token,
    this.createdAt,
  });

  final String? id;
  final String email;
  final String? token;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, email, token, createdAt];
}
