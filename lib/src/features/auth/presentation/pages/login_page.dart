import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../widgets/auth_layout.dart';
import '../widgets/login_bottom_action.dart';
import '../widgets/login_form.dart';
import '../bloc/login/login_bloc.dart';
import '../cubit/login_ui_cubit.dart';

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
      child: BlocProvider(
        create: (_) => LoginUiCubit(),
        child: AuthLayout(
          title: 'Bienvenido de nuevo',
          subtitle: 'Ingresa tus credenciales para continuar administrando tus productos.',
          form: const LoginForm(),
          bottomAction: const LoginBottomAction(),
          icon: Icons.login_rounded,
        ),
      ),
    );
  }
}

