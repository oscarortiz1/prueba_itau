import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomeShortcutCarousel extends StatefulWidget {
  const HomeShortcutCarousel({super.key});

  @override
  State<HomeShortcutCarousel> createState() => _HomeShortcutCarouselState();
}

class _HomeShortcutCarouselState extends State<HomeShortcutCarousel> {
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
    const shortcuts = <_ShortcutConfig>[
      _ShortcutConfig(
        icon: Icons.savings_outlined,
        title: 'Ahorros',
        subtitle: 'Revisa saldos y movimientos al instante.',
      ),
      _ShortcutConfig(
        icon: Icons.credit_card_outlined,
        title: 'Tarjetas',
        subtitle: 'Pagos, cupo disponible y beneficios exclusivos.',
      ),
      _ShortcutConfig(
        icon: Icons.payments_outlined,
        title: 'Pagos',
        subtitle: 'Programa pagos recurrentes y transacciones rapidas.',
      ),
      _ShortcutConfig(
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
                child: _ShortcutTile(config: shortcuts[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.config});

  final _ShortcutConfig config;

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
                  child: Icon(config.icon, color: theme.colorScheme.primary, size: 24),
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
              config.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                config.subtitle,
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

class _ShortcutConfig {
  const _ShortcutConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
