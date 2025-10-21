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
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electronico',
            prefixIcon: Icon(Icons.mail_outline),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
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
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
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

