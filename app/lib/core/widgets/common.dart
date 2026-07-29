import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NexoLogo extends StatelessWidget {
  final bool compact;
  const NexoLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          compact
              ? 'assets/images/nexo_360_icon.png'
              : 'assets/images/nexo_360_logo.png',
          width: compact ? 38 : 150,
          height: compact ? 38 : 70,
          fit: BoxFit.contain,
        ),
        if (compact) ...[
          const SizedBox(width: 10),
          const Text('NEXO 360', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ],
    );
  }
}

class PageHeading extends StatelessWidget {
  final String title;
  final String description;
  final Widget? action;
  const PageHeading({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: NexoColors.muted)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String? badge;
  final Color? color;
  const ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.badge,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (badge != null)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(badge!, style: const TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(description, style: const TextStyle(color: NexoColors.muted)),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 48, color: NexoColors.muted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Confirmar',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirm),
            ),
          ],
        ),
      ) ??
      false;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

class FirestoreError extends StatelessWidget {
  final Object? error;
  const FirestoreError(this.error, {super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(child: Text('No se pudo cargar la información. $error')),
            ],
          ),
        ),
      );
}
