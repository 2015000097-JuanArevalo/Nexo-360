import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/models/event_registration.dart';
import '../../core/services/event_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class RegistrationAdminScreen extends StatefulWidget {
  final AppUser user;
  final EventService? service;

  const RegistrationAdminScreen({super.key, required this.user, this.service});

  @override
  State<RegistrationAdminScreen> createState() =>
      _RegistrationAdminScreenState();
}

class _RegistrationAdminScreenState extends State<RegistrationAdminScreen> {
  late final EventService _service;
  String _filter = 'all';
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EventService();
  }

  Future<void> _setStatus(EventRegistration registration, String status) async {
    final label = _statusLabel(status).toLowerCase();
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Cambiar estado',
      message: 'La inscripción de ${registration.fullName} quedará $label.',
      confirmLabel: _statusLabel(status),
      destructive: status == 'rejected',
    );
    if (!confirmed || !mounted) return;
    setState(() => _processingId = registration.id);
    try {
      await _service.updateRegistrationStatus(
        registrationId: registration.id,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscripción ${_statusLabel(status)}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el estado.')),
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _checkIn(EventRegistration registration) async {
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Registrar ingreso',
      message: 'Confirmar el ingreso de ${registration.fullName}.',
      confirmLabel: 'Registrar ingreso',
    );
    if (!confirmed || !mounted) return;
    setState(() => _processingId = registration.id);
    try {
      await _service.checkIn(registration: registration, user: widget.user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso registrado correctamente.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo participantes aprobados pueden ingresar.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Administrar inscripciones',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Inscripciones del evento',
            description: 'Aprueba, reserva, rechaza y registra el ingreso.',
            accentColor: AppColors.youthCoral,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _filter,
            decoration: const InputDecoration(
              labelText: 'Filtrar por estado',
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Todas')),
              DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
              DropdownMenuItem(value: 'approved', child: Text('Aprobadas')),
              DropdownMenuItem(value: 'reserved', child: Text('En reserva')),
              DropdownMenuItem(value: 'rejected', child: Text('Rechazadas')),
            ],
            onChanged: (value) => setState(() => _filter = value ?? 'all'),
          ),
          const SizedBox(height: 18),
          StreamBuilder<List<EventRegistration>>(
            stream: _service.watchRegistrations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: AppLoadingIndicator(
                    message: 'Cargando inscripciones...',
                  ),
                );
              }
              if (snapshot.hasError) {
                return const AppErrorMessage(
                  message:
                      'No se pudieron consultar las inscripciones. Verifica tu rol y las reglas.',
                );
              }
              final all = snapshot.data ?? const <EventRegistration>[];
              final registrations = _filter == 'all'
                  ? all
                  : all.where((item) => item.status == _filter).toList();
              if (registrations.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.people_outline,
                  title: 'No hay inscripciones',
                  description:
                      'Las nuevas inscripciones públicas aparecerán aquí.',
                );
              }
              return Column(
                children: registrations
                    .map(
                      (registration) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RegistrationCard(
                          registration: registration,
                          processing: _processingId == registration.id,
                          disabled: _processingId != null,
                          onStatus: (status) =>
                              _setStatus(registration, status),
                          onCheckIn: () => _checkIn(registration),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'approved' => 'Aprobada',
      'reserved' => 'En reserva',
      'rejected' => 'Rechazada',
      _ => 'Pendiente',
    };
  }
}

class _RegistrationCard extends StatelessWidget {
  final EventRegistration registration;
  final bool processing;
  final bool disabled;
  final ValueChanged<String> onStatus;
  final VoidCallback onCheckIn;

  const _RegistrationCard({
    required this.registration,
    required this.processing,
    required this.disabled,
    required this.onStatus,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFF3E9F8),
                  foregroundColor: AppColors.violet,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registration.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${registration.organization} · ${registration.email}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                _RegistrationStatusBadge(registration: registration),
              ],
            ),
            const SizedBox(height: 12),
            Text('Teléfono: ${registration.phone}'),
            Text(
              'Enviada: ${formatSchoolDateTime(registration.createdAt)}',
              style: const TextStyle(color: AppColors.muted),
            ),
            if (registration.documentUrl != null) ...[
              const SizedBox(height: 6),
              SelectableText(
                'Documento: ${registration.documentUrl}',
                style: const TextStyle(color: AppColors.royalBlue),
              ),
            ],
            const SizedBox(height: 14),
            if (processing)
              const Center(child: CircularProgressIndicator())
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: disabled || registration.checkedIn
                        ? null
                        : () => onStatus('approved'),
                    child: const Text('Aprobar'),
                  ),
                  OutlinedButton(
                    onPressed: disabled || registration.checkedIn
                        ? null
                        : () => onStatus('reserved'),
                    child: const Text('Reservar'),
                  ),
                  TextButton(
                    onPressed: disabled || registration.checkedIn
                        ? null
                        : () => onStatus('rejected'),
                    child: const Text('Rechazar'),
                  ),
                  if (registration.status == 'approved' &&
                      !registration.checkedIn)
                    FilledButton.icon(
                      onPressed: disabled ? null : onCheckIn,
                      icon: const Icon(Icons.how_to_reg_outlined),
                      label: const Text('Check in'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RegistrationStatusBadge extends StatelessWidget {
  final EventRegistration registration;

  const _RegistrationStatusBadge({required this.registration});

  @override
  Widget build(BuildContext context) {
    if (registration.checkedIn) {
      return const StatusBadge.success('Ingresó');
    }
    return switch (registration.status) {
      'approved' => const StatusBadge.success('Aprobada'),
      'reserved' => const StatusBadge.pending('En reserva'),
      'rejected' => const StatusBadge.danger('Rechazada'),
      _ => const StatusBadge.pending('Pendiente'),
    };
  }
}
