import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../domain/usecases/register_user.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({required RegisterUser registerUser})
      : _registerUser = registerUser,
        super(const RegistrationState()) {
    on<RegistrationEmailChanged>(_onEmailChanged);
    on<RegistrationPasswordChanged>(_onPasswordChanged);
    on<RegistrationConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegistrationSubmitted>(_onSubmitted);
  }

  final RegisterUser _registerUser;

  void _onEmailChanged(
    RegistrationEmailChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(
      state.copyWith(email: event.email, status: RegistrationStatus.initial),
    );
  }

  void _onPasswordChanged(
    RegistrationPasswordChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(
      state.copyWith(password: event.password, status: RegistrationStatus.initial),
    );
  }

  void _onConfirmPasswordChanged(
    RegistrationConfirmPasswordChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        status: RegistrationStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty || state.confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          errorMessage: 'Completa todos los campos.',
        ),
      );
      return;
    }

    if (state.password != state.confirmPassword) {
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          errorMessage: 'Las contraseñas no coinciden.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegistrationStatus.loading, errorMessage: null));

    try {
      await _registerUser(
        RegisterParams(email: state.email, password: state.password),
      );
      emit(state.copyWith(status: RegistrationStatus.success, errorMessage: null));
    } on AppException catch (e) {
      emit(
        state.copyWith(status: RegistrationStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          errorMessage: 'Ocurrio un error inesperado. Intenta de nuevo.',
        ),
      );
    }
  }
}
