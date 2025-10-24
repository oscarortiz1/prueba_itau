import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration/registration_bloc.dart';
import '../cubit/registration_ui_cubit.dart';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: const [
        _EmailField(),
        SizedBox(height: 16),
        _PasswordField(),
        SizedBox(height: 16),
        _ConfirmPasswordField(),
        SizedBox(height: 24),
        _SubmitButton(),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.email != current.email ||
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        String? errorText;
        if (state.status == RegistrationStatus.failure) {
          if (state.email.isEmpty) {
            errorText = 'Requerido';
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            errorText = state.errorMessage;
          }
        }

        return TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo electronico',
            prefixIcon: const Icon(Icons.mail_outline),
            filled: true,
            errorText: errorText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) => context
              .read<RegistrationBloc>()
              .add(RegistrationEmailChanged(value.trim())),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        String? errorText;
        if (state.status == RegistrationStatus.failure) {
          if (state.password.isEmpty) {
            errorText = 'Requerido';
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            final message = state.errorMessage!.toLowerCase();
            if (message.contains('contrasena')) {
              errorText = state.errorMessage;
            }
          }
        }

        return BlocBuilder<RegistrationUiCubit, bool>(
          builder: (context, obscure) {
            return TextField(
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                errorText: errorText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => context.read<RegistrationUiCubit>().toggle(),
                  tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                ),
              ),
              onChanged: (value) => context
                  .read<RegistrationBloc>()
                  .add(RegistrationPasswordChanged(value.trim())),
            );
          },
        );
      },
    );
  }
}

class _ConfirmPasswordField extends StatelessWidget {
  const _ConfirmPasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.confirmPassword != current.confirmPassword ||
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        String? errorText;
        if (state.status == RegistrationStatus.failure) {
          if (state.confirmPassword.isEmpty) {
            errorText = 'Requerido';
          } else if (state.password != state.confirmPassword) {
            errorText = 'No coinciden';
          }
        }

        return BlocBuilder<RegistrationUiCubit, bool>(
          builder: (context, obscure) {
            return TextField(
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                filled: true,
                errorText: errorText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => context.read<RegistrationUiCubit>().toggle(),
                  tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                ),
              ),
              onChanged: (value) => context
                  .read<RegistrationBloc>()
                  .add(RegistrationConfirmPasswordChanged(value.trim())),
            );
          },
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.status == RegistrationStatus.loading
                ? null
                : () => context
                    .read<RegistrationBloc>()
                    .add(const RegistrationSubmitted()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: state.status == RegistrationStatus.loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Registrarme'),
          ),
        );
      },
    );
  }
}
