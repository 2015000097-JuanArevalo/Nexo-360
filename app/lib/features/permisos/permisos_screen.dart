import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/permission_service.dart';
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
        if (user.isTechnical || user.isTeacher) ...[
          NexoModuleCard(
            icon: Icons.qr_code_scanner,
            title: 'Validar QR',
            description: 'Verifica un permiso por cámara o código manual.',
            accentColor: AppColors.primary,
            onTap: () => context.push(AppRoutes.validatePermission),
          ),
          const SizedBox(height: 12),
        ],
        if (user.isTechnical) ...[const _PendingRequestsCard()],
      ],
    );
  }
}

class _PendingRequestsCard extends StatefulWidget {
  const _PendingRequestsCard();

  @override
  State<_PendingRequestsCard> createState() => _PendingRequestsCardState();
}

class _PendingRequestsCardState extends State<_PendingRequestsCard> {
  late final PermissionService _service;

  @override
  void initState() {
    super.initState();
    _service = PermissionService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _service.watchPendingPermissionRequests(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length;
        return NexoModuleCard(
          icon: Icons.approval_outlined,
          title: 'Solicitudes pendientes',
          description: 'Bandeja técnica de aprobación y denegación.',
          accentColor: AppColors.youthCoral,
          badge: count == null ? 'Cargando' : '$count pendientes',
          badgeTone: count == 0 ? StatusTone.success : StatusTone.pending,
          onTap: () => context.push(AppRoutes.pendingPermissionRequests),
        );
      },
    );
  }
}
