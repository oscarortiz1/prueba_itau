import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

class RegistrationBottomAction extends StatelessWidget {
  const RegistrationBottomAction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
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
