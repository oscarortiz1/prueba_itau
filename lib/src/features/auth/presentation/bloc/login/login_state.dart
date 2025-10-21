part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final AuthUser? user;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    AuthUser? user,
    bool clearUser = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: clearUser ? null : (user ?? this.user),
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage, user];
}
