import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/session/session_manager.dart';
import '../../../domain/entities/auth_user.dart';
import '../../../domain/usecases/login_user.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUser loginUser, required SessionManager sessionManager})
      : _loginUser = loginUser,
        _sessionManager = sessionManager,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUser _loginUser;
  final SessionManager _sessionManager;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Debes ingresar correo y contraseña.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final user = await _loginUser(
        LoginParams(email: state.email, password: state.password),
      );
      _sessionManager.updateUser(user);
      emit(
        state.copyWith(
          status: LoginStatus.success,
          errorMessage: null,
          user: user,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Ocurrio un error inesperado. Intenta de nuevo.',
        ),
      );
    }
  }
}
