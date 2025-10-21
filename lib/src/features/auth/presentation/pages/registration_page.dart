import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../widgets/auth_layout.dart';
import '../bloc/registration/registration_bloc.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        final theme = Theme.of(context);
        if (state.status == RegistrationStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Registro exitoso. Ahora puedes iniciar sesion.')),
            );
          context.goNamed(AppRouteName.login);
        } else if (state.status == RegistrationStatus.failure && state.errorMessage != null) {
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
        title: 'Crea tu cuenta',
        subtitle: 'Registrate para acceder a todos los servicios digitales de prueba_itau.',
        form: const _RegistrationForm(),
        bottomAction: const _RegistrationBottomAction(),
        icon: Icons.person_add_alt_1,
      ),
    );
  }
}

class _RegistrationForm extends StatelessWidget {
  const _RegistrationForm();

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
          onChanged: (value) => context
              .read<RegistrationBloc>()
              .add(RegistrationPasswordChanged(value.trim())),
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
      buildWhen: (previous, current) => previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        return TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirmar Contraseña',
            prefixIcon: Icon(Icons.verified_user_outlined),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
          onChanged: (value) => context
              .read<RegistrationBloc>()
              .add(RegistrationConfirmPasswordChanged(value.trim())),
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
                : () =>
                    context.read<RegistrationBloc>().add(const RegistrationSubmitted()),
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

class _RegistrationBottomAction extends StatelessWidget {
  const _RegistrationBottomAction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ya tienes una cuenta?',
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.goNamed(AppRouteName.login),
          child: const Text('Iniciar sesion'),
        ),
      ],
    );
  }
}
