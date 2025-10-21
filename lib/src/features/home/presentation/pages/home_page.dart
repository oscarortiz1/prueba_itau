import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/di/injection_container.dart';
import '../../../../core/session/session_manager.dart';
import '../../../transactions/presentation/widgets/transactions_section.dart';

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
                    _HeroSection(isWide: isWide),
                    const SizedBox(height: 32),
                    _ShortcutGrid(isWide: isWide),
                    const SizedBox(height: 32),
                    const TransactionsSection(),
                    const SizedBox(height: 32),
                    _InsightsSection(isWide: isWide),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final heroContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, bienvenido a Prueba itau',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Administra tus cuentas, inversiones y pagos en un mismo lugar con informacion en tiempo real.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Ver productos'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Contactar soporte'),
            ),
          ],
        ),
      ],
    );

    final heroIllustration = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.show_chart, color: Colors.white, size: 40),
            SizedBox(height: 24),
            Text(
              'Tus finanzas a un vistazo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Controla gastos, ingresos y objetivos con herramientas inteligentes.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: heroContent),
                  const SizedBox(width: 32),
                  Expanded(child: heroIllustration),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heroContent,
                  const SizedBox(height: 32),
                  heroIllustration,
                ],
              ),
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _ShortcutTile(
        icon: Icons.savings_outlined,
        title: 'Ahorros',
        subtitle: 'Revisa saldos y movimientos al instante.',
      ),
      _ShortcutTile(
        icon: Icons.credit_card_outlined,
        title: 'Tarjetas',
        subtitle: 'Pagos, cupo disponible y beneficios exclusivos.',
      ),
      _ShortcutTile(
        icon: Icons.payments_outlined,
        title: 'Pagos',
        subtitle: 'Programa pagos recurrentes y transacciones rapidas.',
      ),
      _ShortcutTile(
        icon: Icons.trending_up_outlined,
        title: 'Inversiones',
        subtitle: 'Sigue el rendimiento de tus portafolios.',
      ),
    ];

  final screenWidth = MediaQuery.of(context).size.width;
  final isMedium = screenWidth >= 720;
  final crossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);
  // Ajuste de aspect ratio para evitar overflow vertical en tarjetas
  final aspectRatio = isWide
    ? 1.15
    : (isMedium
      ? 1.45
      : 2.1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: aspectRatio,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) => shortcuts[index],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final insightCards = [
      _InsightCard(
        title: 'Resumen mensual',
               value: ' \$ 2.450.000',
        description: 'Ingresos netos registrados este mes.',
        icon: Icons.calendar_month_outlined,
      ),
      _InsightCard(
        title: 'Objetivo de ahorro',
        value: '65 %',
        description: 'Progreso del objetivo anual de ahorro.',
        icon: Icons.flag_outlined,
      ),
      _InsightCard(
        title: 'Pagos programados',
        value: '3',
        description: 'Pagos automaticos por ejecutar esta semana.',
        icon: Icons.schedule_outlined,
      ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights rapidos',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (isWide)
              Row(
                children: List.generate(
                  insightCards.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == insightCards.length - 1 ? 0 : 16,
                      ),
                      child: insightCards[index],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: List.generate(
                  insightCards.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == insightCards.length - 1 ? 0 : 16,
                    ),
                    child: insightCards[index],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
