import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event_registration.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/event_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class RegistrationStatusScreen extends StatefulWidget {
  final String? registrationId;
  final EventService? service;

  const RegistrationStatusScreen({
    super.key,
    this.registrationId,
    this.service,
  });

  @override
  State<RegistrationStatusScreen> createState() =>
      _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState extends State<RegistrationStatusScreen> {
  final _codeController = TextEditingController();
  late final EventService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EventService();
    _codeController.text = widget.registrationId ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _search() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context.go(AppRoutes.registrationStatusFor(code));
  }

  @override
  Widget build(BuildContext context) {
    final registrationId = widget.registrationId?.trim();
    return PrototypeScreen(
      title: 'Estado de inscripción',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Consulta tu inscripción',
            description:
                'El estado se actualiza cuando el organizador procesa tu solicitud.',
            accentColor: AppColors.youthCoral,
          ),
          const SizedBox(height: 18),
          NexoTextFormField(
            controller: _codeController,
            label: 'Código de seguimiento',
            icon: Icons.confirmation_number_outlined,
            onFieldSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('Consultar estado'),
          ),
          const SizedBox(height: 18),
          if (registrationId == null || registrationId.isEmpty)
            const AppEmptyState(
              icon: Icons.manage_search_outlined,
              title: 'Ingresa tu código',
              description:
                  'El código fue mostrado al completar la inscripción.',
            )
          else
            StreamBuilder<EventRegistration?>(
              stream: _service.watchRegistration(registrationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 230,
                    child: AppLoadingIndicator(
                      message: 'Consultando inscripción...',
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const AppErrorMessage(
                    message:
                        'No fue posible consultar el estado. Revisa el código y las reglas.',
                  );
                }
                final registration = snapshot.data;
                if (registration == null) {
                  return const AppEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'Inscripción no encontrada',
                    description: 'Verifica que el código esté completo.',
                  );
                }
                return _StatusCard(registration: registration);
              },
            ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.publicRegistration),
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Realizar otra inscripción'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final EventRegistration registration;

  const _StatusCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(registration);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: presentation.background,
        border: Border.all(color: presentation.color, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(presentation.icon, color: presentation.color, size: 58),
          const SizedBox(height: 10),
          Text(
            presentation.label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: presentation.color),
          ),
          const SizedBox(height: 8),
          Text(
            registration.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Enviada ${formatSchoolDateTime(registration.createdAt)}',
            style: const TextStyle(color: AppColors.muted),
          ),
          if (registration.checkedIn) ...[
            const Divider(height: 28),
            const StatusBadge.success('Ingreso registrado'),
            if (registration.checkedInAt != null) ...[
              const SizedBox(height: 6),
              Text(
                formatSchoolDateTime(registration.checkedInAt!),
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ],
        ],
      ),
    );
  }

  _StatusPresentation _presentation(EventRegistration registration) {
    return switch (registration.status) {
      'approved' => const _StatusPresentation(
        label: 'APROBADA',
        icon: Icons.verified_outlined,
        color: AppColors.success,
        background: AppColors.successSurface,
      ),
      'reserved' => const _StatusPresentation(
        label: 'EN RESERVA',
        icon: Icons.schedule_outlined,
        color: AppColors.pending,
        background: AppColors.pendingSurface,
      ),
      'rejected' => const _StatusPresentation(
        label: 'RECHAZADA',
        icon: Icons.cancel_outlined,
        color: AppColors.danger,
        background: AppColors.dangerSurface,
      ),
      _ => const _StatusPresentation(
        label: 'PENDIENTE',
        icon: Icons.hourglass_top_outlined,
        color: AppColors.pending,
        background: AppColors.pendingSurface,
      ),
    };
  }
}

class _StatusPresentation {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}
