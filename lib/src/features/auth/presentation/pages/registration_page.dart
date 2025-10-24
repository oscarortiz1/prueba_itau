import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../widgets/auth_layout.dart';
import '../widgets/registration_bottom_action.dart';
import '../widgets/registration_form.dart';
import '../bloc/registration/registration_bloc.dart';
import '../cubit/registration_ui_cubit.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        final theme = Theme.of(context);
        if (state.status == RegistrationStatus.success) {
          final successBackground = Colors.green.shade600;
          final successForeground = Colors.white;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Registro exitoso. Ahora puedes iniciar sesion.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: successForeground),
                ),
                backgroundColor: successBackground,
                behavior: SnackBarBehavior.floating,
              ),
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
      child: BlocProvider(
        create: (_) => RegistrationUiCubit(),
        child: AuthLayout(
          title: 'Crea tu cuenta',
          subtitle: 'Registrate para acceder a todos los servicios digitales de prueba_itau.',
          form: const RegistrationForm(),
          bottomAction: const RegistrationBottomAction(),
          icon: Icons.person_add_alt_1,
        ),
      ),
    );
  }
}
