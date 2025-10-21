import 'package:flutter/material.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({required this.isWide, super.key});

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
              style: TextStyle(color: Colors.white70, fontSize: 16),
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
