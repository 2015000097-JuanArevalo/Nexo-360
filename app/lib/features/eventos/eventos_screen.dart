import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class EventosScreen extends StatelessWidget {
  final AppUser user;

  const EventosScreen({super.key, required this.user});

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
        NexoModuleCard(
          icon: Icons.event_available_outlined,
          title: 'Encuentro Juvenil NEXO 2026',
          description: '18 de julio · Colegio Don Bosco · cupos limitados.',
          accentColor: AppColors.youthCoral,
          badge: 'Inscripción abierta',
          badgeTone: StatusTone.success,
          onTap: () => context.push(AppRoutes.publicRegistration),
        ),
        if (user.canManageEventRegistrations) ...[
          const SizedBox(height: 12),
          NexoModuleCard(
            icon: Icons.people_alt_outlined,
            title: 'Administrar inscripciones',
            description: 'Revisa, aprueba, reserva o rechaza participantes.',
            accentColor: AppColors.violet,
            badge: '8 pendientes',
            badgeTone: StatusTone.pending,
            onTap: () => context.push(AppRoutes.registrationAdmin),
          ),
        ],
        if (user.isEventCommissioner) ...[
          const SizedBox(height: 12),
          const NexoModuleCard(
            icon: Icons.task_alt_outlined,
            title: 'Mi comisión',
            description: 'Acciones limitadas según eventPermissions.',
            accentColor: AppColors.cyan,
            badge: 'Comisionado',
          ),
        ],
        const SizedBox(height: 12),
        const NexoModuleCard(
          icon: Icons.map_outlined,
          title: 'Mapa e información',
          description: 'Vista preliminar del croquis y puntos del evento.',
          accentColor: AppColors.royalBlue,
          badge: 'Próximamente',
        ),
      ],
    );
  }
}
