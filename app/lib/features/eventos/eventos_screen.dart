import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/models/event_record.dart';
import '../../core/models/event_registration.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/event_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class EventosScreen extends StatefulWidget {
  final AppUser user;

  const EventosScreen({super.key, required this.user});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late final EventService _service;

  @override
  void initState() {
    super.initState();
    _service = EventService();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Movimiento Juventud',
          description: 'Información, inscripciones y coordinación del evento.',
          accentColor: AppColors.youthCoral,
        ),
        const SizedBox(height: 20),
        if (widget.user.canCreateEvents) ...[
          NexoModuleCard(
            icon: Icons.add_circle_outline,
            title: 'Crear nuevo evento',
            description:
                'Define nombre, fecha, ubicación, capacidad y apertura de inscripciones.',
            accentColor: AppColors.violet,
            badge: widget.user.isTechnical ? 'Técnico' : 'Organizador',
            onTap: () => context.push(AppRoutes.createEvent),
          ),
          const SizedBox(height: 12),
        ],
        StreamBuilder<List<EventRecord>>(
          stream: _service.watchEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 170,
                child: AppLoadingIndicator(message: 'Cargando eventos...'),
              );
            }
            if (snapshot.hasError) {
              return const AppErrorMessage(
                message: 'No se pudieron consultar los eventos.',
              );
            }
            final events = snapshot.data ?? const <EventRecord>[];
            if (events.isEmpty) {
              return AppEmptyState(
                icon: Icons.event_busy_outlined,
                title: 'No hay eventos',
                description: 'Crea el primer evento para comenzar.',
                action: widget.user.canCreateEvents
                    ? FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.createEvent),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Crear evento'),
                      )
                    : null,
              );
            }
            return Column(
              children: [
                ...events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NexoModuleCard(
                      icon: Icons.event_available_outlined,
                      title: event.name,
                      description: _eventDescription(event),
                      accentColor: AppColors.youthCoral,
                      badge: !event.isPublic
                          ? 'Privado'
                          : event.registrationOpen
                          ? 'Inscripción abierta'
                          : 'Inscripción cerrada',
                      badgeTone: !event.isPublic
                          ? StatusTone.info
                          : event.registrationOpen
                          ? StatusTone.success
                          : StatusTone.danger,
                      onTap: event.isPublic && event.registrationOpen
                          ? () => context.push(
                              Uri(
                                path: AppRoutes.publicRegistration,
                                queryParameters: {'eventId': event.id},
                              ).toString(),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        NexoModuleCard(
          icon: Icons.manage_search_outlined,
          title: 'Consultar mi inscripción',
          description: 'Usa el código recibido al enviar el formulario.',
          accentColor: AppColors.royalBlue,
          onTap: () => context.push(AppRoutes.registrationStatus),
        ),
        if (widget.user.canManageEventRegistrations) ...[
          const SizedBox(height: 12),
          _RegistrationAdminCard(service: _service),
        ],
        if (widget.user.isEventCommissioner) ...[
          const SizedBox(height: 12),
          const NexoModuleCard(
            icon: Icons.task_alt_outlined,
            title: 'Mi comisión',
            description: 'Vista secundaria pendiente de implementación.',
            accentColor: AppColors.cyan,
            badge: 'Prototipo',
          ),
        ],
        const SizedBox(height: 12),
        const NexoModuleCard(
          icon: Icons.map_outlined,
          title: 'Mapa e información',
          description: 'Vista preliminar del croquis y puntos del evento.',
          accentColor: AppColors.royalBlue,
          badge: 'Prototipo',
        ),
      ],
    );
  }

  String _eventDescription(EventRecord event) {
    final hasDate = event.date.millisecondsSinceEpoch > 0;
    final date = hasDate
        ? formatSchoolDateTime(event.date)
        : 'Fecha por confirmar';
    final capacity = event.capacity > 0
        ? 'capacidad ${event.capacity}'
        : 'capacidad por confirmar';
    return '$date · ${event.location} · $capacity';
  }
}

class _RegistrationAdminCard extends StatelessWidget {
  final EventService service;

  const _RegistrationAdminCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventRegistration>>(
      stream: service.watchRegistrations(),
      builder: (context, snapshot) {
        final pending =
            snapshot.data
                ?.where((registration) => registration.status == 'pending')
                .length ??
            0;
        return NexoModuleCard(
          icon: Icons.people_alt_outlined,
          title: 'Administrar inscripciones',
          description: 'Revisa, aprueba, reserva o rechaza participantes.',
          accentColor: AppColors.violet,
          badge: snapshot.connectionState == ConnectionState.waiting
              ? 'Cargando'
              : '$pending pendientes',
          badgeTone: pending == 0 ? StatusTone.success : StatusTone.pending,
          onTap: () => context.push(AppRoutes.registrationAdmin),
        );
      },
    );
  }
}
