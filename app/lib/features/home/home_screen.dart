import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final cards = _cardsFor(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${user.displayName}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${user.accountLabel} · ${user.eventRoleLabel}',
                      style: const TextStyle(color: Color(0xFFDCE1FF)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Portal Escolar · Permisos · Movimiento Juventud',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.hub_outlined,
                size: 64,
                color: Color(0x99FFFFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PageHeading(
          title: 'Accesos para ${user.accountLabel.toLowerCase()}',
          description: _roleDescription(user),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      child: NexoModuleCard(
                        icon: card.icon,
                        title: card.title,
                        description: card.description,
                        accentColor: card.color,
                        badge: card.badge,
                        badgeTone: card.badgeTone,
                        onTap: () => context.push(card.path),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  List<_DashboardItem> _cardsFor(AppUser user) {
    final items = <_DashboardItem>[
      const _DashboardItem(
        icon: Icons.assignment_outlined,
        title: 'Avisos y actividades',
        description: 'Consulta el trabajo escolar y los anuncios de tu clase.',
        path: AppRoutes.assignments,
        color: AppColors.royalBlue,
      ),
    ];

    if (user.isStudent) {
      items.add(
        const _DashboardItem(
          icon: Icons.qr_code_2,
          title: 'Mi permiso y QR',
          description: 'Consulta la vigencia y presenta tu código personal.',
          path: AppRoutes.studentPermission,
          color: AppColors.cyan,
          badge: 'Estudiante',
          badgeTone: StatusTone.success,
        ),
      );
    }

    if (user.canCreatePermission || user.canRequestPermission) {
      items.add(
        _DashboardItem(
          icon: Icons.add_task_outlined,
          title: user.canCreatePermission
              ? 'Crear permiso'
              : 'Solicitar permiso',
          description: user.canCreatePermission
              ? 'Registra un permiso estudiantil directamente.'
              : 'Envía una solicitud para revisión del personal técnico.',
          path: AppRoutes.createPermission,
          color: AppColors.violet,
        ),
      );
    }

    items.add(
      const _DashboardItem(
        icon: Icons.qr_code_scanner,
        title: 'Consultar QR',
        description: 'Verifica un permiso por cámara o código manual.',
        path: AppRoutes.validatePermission,
        color: AppColors.primary,
      ),
    );

    items.add(
      const _DashboardItem(
        icon: Icons.event_available_outlined,
        title: 'Eventos y registro',
        description: 'Consulta Movimiento Juventud y completa una inscripción.',
        path: AppRoutes.events,
        color: AppColors.youthCoral,
      ),
    );

    if (user.canManageEventRegistrations) {
      items.add(
        const _DashboardItem(
          icon: Icons.people_alt_outlined,
          title: 'Administrar inscripciones',
          description: 'Revisa participantes pendientes y aprobados.',
          path: AppRoutes.registrationAdmin,
          color: AppColors.violet,
          badge: 'Organización',
        ),
      );
    }

    return items;
  }

  String _roleDescription(AppUser user) {
    if (user.isTechnical) {
      return 'Administración, creación de permisos y consulta de códigos QR.';
    }
    if (user.isTeacher && user.isEventOrganizer) {
      return 'Gestión escolar, solicitudes de permisos y administración de eventos.';
    }
    if (user.isTeacher) {
      return 'Actividades escolares, solicitudes de permisos y consulta de QR.';
    }
    if (user.isEventOrganizer) {
      return 'Consulta estudiantil y herramientas de organización de eventos.';
    }
    return 'Actividades escolares, permiso personal e información de eventos.';
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;
  final String description;
  final String path;
  final Color color;
  final String? badge;
  final StatusTone badgeTone;

  const _DashboardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
    required this.color,
    this.badge,
    this.badgeTone = StatusTone.info,
  });
}
