import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/widgets/nexo_ui.dart';
import 'permission_form_screen.dart';
import 'qr_validation_screen.dart';
import 'student_qr_screen.dart';

class PermisosScreen extends StatelessWidget {
  final AppUser user;

  const PermisosScreen({super.key, required this.user});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Permisos',
          description: 'Permisos estudiantiles, solicitudes y consulta por QR.',
        ),
        const SizedBox(height: 20),
        if (user.isStudent) ...[
          NexoModuleCard(
            icon: Icons.badge_outlined,
            title: 'Mi permiso y QR',
            description: 'Presenta tu código y consulta su vigencia.',
            onTap: () => _open(context, StudentQrScreen(user: user)),
          ),
          const SizedBox(height: 12),
        ],
        if (user.isTechnical || user.isTeacher || user.isEventOrganizer) ...[
          NexoModuleCard(
            icon: Icons.add_task_outlined,
            title: user.isTechnical ? 'Crear permiso' : 'Solicitar permiso',
            description: user.isTechnical
                ? 'Crea un permiso real para un estudiante.'
                : 'Envía una solicitud pendiente de aprobación técnica.',
            onTap: () => _open(context, PermissionFormScreen(user: user)),
          ),
          const SizedBox(height: 12),
        ],
        NexoModuleCard(
          icon: Icons.qr_code_scanner,
          title: 'Consultar QR',
          description: 'Consulta el estado del permiso de un estudiante.',
          onTap: () => _open(context, const QrValidationScreen()),
        ),
        if (user.isTechnical) ...[
          const SizedBox(height: 12),
          const NexoModuleCard(
            icon: Icons.approval_outlined,
            title: 'Solicitudes pendientes',
            description: 'Bandeja técnica de aprobación y denegación.',
            badge: '3 pendientes',
          ),
        ],
      ],
    );
  }
}
