import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/widgets/nexo_ui.dart';
import 'activity_board_screen.dart';

class PortalEscolarScreen extends StatelessWidget {
  final AppUser user;

  const PortalEscolarScreen({super.key, required this.user});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Portal Escolar',
          description: 'Información académica según tu tipo de cuenta.',
        ),
        const SizedBox(height: 20),
        NexoModuleCard(
          icon: Icons.assignment_outlined,
          title: 'Avisos y actividades',
          description: user.isStudent
              ? 'Consulta tareas, anuncios y fechas de entrega.'
              : 'Publica y administra contenido para tus clases.',
          onTap: () => _open(context, ActivityBoardScreen(user: user)),
        ),
        const SizedBox(height: 12),
        const NexoModuleCard(
          icon: Icons.calendar_month_outlined,
          title: 'Horarios',
          description: 'Vista preliminar del horario escolar.',
          badge: 'Próximamente',
        ),
        const SizedBox(height: 12),
        const NexoModuleCard(
          icon: Icons.fact_check_outlined,
          title: 'Asistencia y notas',
          description: 'Resumen visual incluido fuera del flujo crítico.',
          badge: 'Próximamente',
        ),
      ],
    );
  }
}
