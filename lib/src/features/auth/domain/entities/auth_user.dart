import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
