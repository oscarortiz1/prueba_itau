import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../../transactions/presentation/widgets/transactions_section.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_shortcut_carousel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: theme.colorScheme.primary,
        title: const Text('Panel principal'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion'),
              onPressed: () async {
                await sl<SessionManager>().clear();
                if (context.mounted) {
                  context.goNamed(AppRouteName.login);
                }
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeroSection(isWide: isWide),
                    const SizedBox(height: 32),
                    BlocProvider(
                      create: (_) =>
                         TransactionsUiCubit(),
                      child: const TransactionsSection(),
                    ),
                    const SizedBox(height: 32),
                    const HomeShortcutCarousel(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
