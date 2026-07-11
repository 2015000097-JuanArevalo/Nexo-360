import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/widgets/nexo_ui.dart';
import 'event_registration_screen.dart';
import 'registration_admin_screen.dart';

class EventosScreen extends StatelessWidget {
  final AppUser user;

  const EventosScreen({super.key, required this.user});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final canAdmin = user.isTechnical || user.isEventOrganizer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Eventos',
          description: 'Información, inscripciones y administración del evento.',
        ),
        const SizedBox(height: 20),
        NexoModuleCard(
          icon: Icons.event_available_outlined,
          title: 'Evento activo',
          description: 'Encuentro Juvenil NEXO 2026 · 18 de julio.',
          badge: 'Inscripción abierta',
          onTap: () => _open(context, const EventRegistrationScreen()),
        ),
        if (canAdmin) ...[
          const SizedBox(height: 12),
          NexoModuleCard(
            icon: Icons.people_alt_outlined,
            title: 'Administrar inscripciones',
            description: 'Revisa, aprueba, reserva o rechaza participantes.',
            badge: '8 pendientes',
            onTap: () => _open(context, const RegistrationAdminScreen()),
          ),
        ],
        if (user.isEventCommissioner) ...[
          const SizedBox(height: 12),
          const NexoModuleCard(
            icon: Icons.task_alt_outlined,
            title: 'Mi comisión',
            description: 'Acciones limitadas por eventPermissions.',
            badge: 'Próximamente',
          ),
        ],
        const SizedBox(height: 12),
        const NexoModuleCard(
          icon: Icons.map_outlined,
          title: 'Mapa e información',
          description: 'Vista preliminar del croquis y puntos del evento.',
          badge: 'Próximamente',
        ),
      ],
    );
  }
}
