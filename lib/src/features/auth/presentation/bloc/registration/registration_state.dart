part of 'registration_bloc.dart';

enum RegistrationStatus { initial, loading, success, failure }

class RegistrationState extends Equatable {
  const RegistrationState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegistrationStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final RegistrationStatus status;
  final String? errorMessage;

  RegistrationState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    RegistrationStatus? status,
    String? errorMessage,
  }) {
    return RegistrationState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, confirmPassword, status, errorMessage];
}
