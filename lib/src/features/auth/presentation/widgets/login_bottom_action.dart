import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

class LoginBottomAction extends StatelessWidget {
  const LoginBottomAction({super.key});

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
