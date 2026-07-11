import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class PermisosScreen extends StatelessWidget {
  final AppUser user;

  const PermisosScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Permisos',
          description: 'Permisos estudiantiles, solicitudes y consulta por QR.',
          accentColor: AppColors.cyan,
        ),
        const SizedBox(height: 20),
        if (user.isStudent) ...[
          NexoModuleCard(
            icon: Icons.badge_outlined,
            title: 'Mi permiso y QR',
            description: 'Presenta tu código y consulta su vigencia.',
            accentColor: AppColors.cyan,
            badge: 'Estudiante',
            badgeTone: StatusTone.success,
            onTap: () => context.push(AppRoutes.studentPermission),
          ),
          const SizedBox(height: 12),
        ],
        if (user.canCreatePermission || user.canRequestPermission) ...[
          NexoModuleCard(
            icon: Icons.add_task_outlined,
            title: user.canCreatePermission
                ? 'Crear permiso'
                : 'Solicitar permiso',
            description: user.canCreatePermission
                ? 'Crea un permiso real para un estudiante.'
                : 'Envía una solicitud pendiente de aprobación técnica.',
            accentColor: AppColors.violet,
            onTap: () => context.push(AppRoutes.createPermission),
          ),
          const SizedBox(height: 12),
        ],
        NexoModuleCard(
          icon: Icons.qr_code_scanner,
          title: 'Consultar QR',
          description: 'Consulta el estado del permiso de un estudiante.',
          accentColor: AppColors.primary,
          onTap: () => context.push(AppRoutes.validatePermission),
        ),
        if (user.isTechnical) ...[
          const SizedBox(height: 12),
          const NexoModuleCard(
            icon: Icons.approval_outlined,
            title: 'Solicitudes pendientes',
            description: 'Bandeja técnica de aprobación y denegación.',
            accentColor: AppColors.youthCoral,
            badge: '3 pendientes',
            badgeTone: StatusTone.pending,
          ),
        ],
      ],
    );
  }
}
