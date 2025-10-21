import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../widgets/auth_layout.dart';
import '../bloc/login/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        final theme = Theme.of(context);
        if (state.status == LoginStatus.success) {
          context.goNamed(AppRouteName.home);
        } else if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.onError),
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: AuthLayout(
        title: 'Bienvenido de nuevo',
        subtitle: 'Ingresa tus credenciales para continuar administrando tus productos.',
  form: const _LoginForm(),
  bottomAction: const _LoginBottomAction(),
        icon: Icons.login_rounded,
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: const [
        _EmailField(),
        SizedBox(height: 16),
        _PasswordField(),
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email || previous.status != current.status || previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        String? errorText;
        if (state.status == LoginStatus.failure) {
          if (state.email.isEmpty) {
            errorText = 'Requerido';
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            // show server/auth error on the field as well
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
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
            ),
          ),
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginEmailChanged(value.trim())),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password || previous.status != current.status || previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        String? errorText;
        if (state.status == LoginStatus.failure) {
          if (state.password.isEmpty) {
            errorText = 'Requerido';
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            // avoid duplicating message on both fields unless specific
            if (state.errorMessage!.toLowerCase().contains('contrasena') || state.errorMessage!.toLowerCase().contains('credenciales')) {
              errorText = state.errorMessage;
            }
          }
        }

        return TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            filled: true,
            errorText: errorText,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
            ),
          ),
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(value.trim())),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.status == LoginStatus.loading
                ? null
                : () => context.read<LoginBloc>().add(const LoginSubmitted()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: state.status == LoginStatus.loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Ingresar'),
          ),
        );
      },
    );
  }
}

class _LoginBottomAction extends StatelessWidget {
  const _LoginBottomAction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Aun no tienes una cuenta?',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.goNamed(AppRouteName.register),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}

