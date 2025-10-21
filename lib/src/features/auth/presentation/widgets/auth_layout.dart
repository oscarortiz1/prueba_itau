import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.bottomAction,
    this.icon = Icons.lock_outline,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? bottomAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final formCard = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 36,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(icon, size: 32, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        form,
                        if (bottomAction != null) ...[
                          const SizedBox(height: 28),
                          bottomAction!,
                        ],
                      ],
                    ),
                  ),
                ),
              );

              final infoPanel = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _InfoPanel(theme: theme),
                ),
              );

              final content = isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        infoPanel,
                        const SizedBox(width: 28),
                        formCard,
                      ],
                    )
                  : formCard;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.center,
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Prueba Itau',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gestiona tus productos financieros con una experiencia simple y segura.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HighlightChip(icon: Icons.security, label: 'Seguridad garantizada'),
              _HighlightChip(icon: Icons.flash_on, label: 'Procesos agiles'),
              _HighlightChip(icon: Icons.support_agent, label: 'Soporte 24/7'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = colorScheme.primaryContainer.withValues(alpha: 0.32);
    final foreground = colorScheme.onPrimaryContainer.withValues(alpha: 0.9);
    final borderColor = colorScheme.primary.withValues(alpha: 0.35);

    return Chip(
      avatar: Icon(icon, color: foreground, size: 18),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
      ),
      backgroundColor: background,
      side: BorderSide(color: borderColor, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
