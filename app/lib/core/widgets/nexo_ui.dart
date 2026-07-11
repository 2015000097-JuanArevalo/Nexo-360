import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

enum StatusTone { info, success, pending, danger }

class NexoLogo extends StatelessWidget {
  final bool compact;

  const NexoLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 48,
          height: compact ? 34 : 48,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(compact ? 11 : 15),
            boxShadow: const [
              BoxShadow(color: Color(0x3300A4D6), blurRadius: 12),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 22 : 31,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'NEXO 360',
          style: TextStyle(
            color: compact ? Colors.white : AppColors.primary,
            fontSize: compact ? 18 : 25,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
      ],
    );
  }
}

class NexoBrandPanel extends StatelessWidget {
  final double size;

  const NexoBrandPanel({super.key, this.size = 210});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/nexo_360_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Logo NEXO 360',
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  final String title;
  final String description;
  final Color accentColor;

  const PageHeading({
    super.key,
    required this.title,
    required this.description,
    this.accentColor = AppColors.royalBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 54,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

class NexoModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String? badge;
  final StatusTone badgeTone;
  final Color accentColor;

  const NexoModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.badge,
    this.badgeTone = StatusTone.info,
    this.accentColor = AppColors.royalBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: .11),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: accentColor),
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                if (badge != null)
                                  StatusBadge(label: badge!, tone: badgeTone),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.info,
  });

  const StatusBadge.success(String label, {Key? key})
    : this(key: key, label: label, tone: StatusTone.success);

  const StatusBadge.pending(String label, {Key? key})
    : this(key: key, label: label, tone: StatusTone.pending);

  const StatusBadge.danger(String label, {Key? key})
    : this(key: key, label: label, tone: StatusTone.danger);

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.success => (AppColors.success, AppColors.successSurface),
      StatusTone.pending => (AppColors.pending, AppColors.pendingSurface),
      StatusTone.danger => (AppColors.danger, AppColors.dangerSurface),
      StatusTone.info => (AppColors.primary, const Color(0xFFE7E9F8)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  final String message;

  const AppLoadingIndicator({super.key, this.message = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.cyan),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class AppErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class NexoTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  const NexoTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

Future<bool> showNexoConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        destructive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: destructive ? AppColors.danger : AppColors.royalBlue,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

class PrototypeNotice extends StatelessWidget {
  final String message;

  const PrototypeNotice({
    super.key,
    this.message =
        'Base visual y navegación listas. La persistencia de este flujo se conecta en el siguiente milestone.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E9F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class PrototypeScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showDashboardAction;

  const PrototypeScreen({
    super.key,
    required this.title,
    required this.child,
    this.showDashboardAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: showDashboardAction
            ? [
                IconButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  tooltip: 'Volver al dashboard',
                  icon: const Icon(Icons.dashboard_outlined),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NexoSplashScreen extends StatelessWidget {
  const NexoSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: NexoBrandPanel(size: 190)),
          SizedBox(height: 20),
          CircularProgressIndicator(color: AppColors.cyan),
        ],
      ),
    );
  }
}
