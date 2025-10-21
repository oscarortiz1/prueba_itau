import 'package:flutter/gestures.dart';
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
                    const SizedBox(height: 32),
                    const TransactionsSection(),
                    const SizedBox(height: 32),
                    const _ShortcutCarousel(),
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

class _ShortcutCarousel extends StatefulWidget {
  const _ShortcutCarousel();

  @override
  State<_ShortcutCarousel> createState() => _ShortcutCarouselState();
}

class _ShortcutCarouselState extends State<_ShortcutCarousel> {
  PageController? _controller;
  double? _viewportFraction;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _ensureController(double fraction, int itemCount) {
    if (_controller == null) {
      _controller = PageController(viewportFraction: fraction);
      _viewportFraction = fraction;
      return;
    }

    if (_viewportFraction != null && (_viewportFraction! - fraction).abs() < 0.001) {
      return;
    }

    final oldController = _controller!;
    final initialPage = oldController.hasClients
        ? (oldController.page ?? oldController.initialPage.toDouble()).round()
        : oldController.initialPage;
  final safeInitialPage = itemCount <= 0
    ? 0
    : initialPage.clamp(0, itemCount - 1).toInt();

    _viewportFraction = fraction;
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: safeInitialPage,
    );
    oldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <Widget>[
      const _ShortcutTile(
        icon: Icons.savings_outlined,
        title: 'Ahorros',
        subtitle: 'Revisa saldos y movimientos al instante.',
      ),
      const _ShortcutTile(
        icon: Icons.credit_card_outlined,
        title: 'Tarjetas',
        subtitle: 'Pagos, cupo disponible y beneficios exclusivos.',
      ),
      const _ShortcutTile(
        icon: Icons.payments_outlined,
        title: 'Pagos',
        subtitle: 'Programa pagos recurrentes y transacciones rapidas.',
      ),
      const _ShortcutTile(
        icon: Icons.trending_up_outlined,
        title: 'Inversiones',
        subtitle: 'Sigue el rendimiento de tus portafolios.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = width >= 1100
            ? 0.32
            : width >= 720
                ? 0.48
                : 0.88;
  _ensureController(fraction, shortcuts.length);

        final cardHeight = width >= 720 ? 220.0 : 210.0;
        final horizontalPadding = width >= 720 ? 16.0 : 12.0;

        return SizedBox(
          height: cardHeight,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: const {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PageView.builder(
              controller: _controller!,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              padEnds: width < 720,
              itemCount: shortcuts.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: shortcuts[index],
              ),
            ),
          ),
        );
      },
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
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
