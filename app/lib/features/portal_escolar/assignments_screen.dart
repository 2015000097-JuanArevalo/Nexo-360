import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class AssignmentsScreen extends StatelessWidget {
  final AppUser user;

  const AssignmentsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Avisos y actividades',
          description: user.canPublishSchoolContent
              ? 'Publica contenido escolar para las clases asignadas.'
              : 'Consulta las actividades y anuncios de tu clase.',
          accentColor: AppColors.royalBlue,
        ),
        const SizedBox(height: 18),
        if (user.canPublishSchoolContent) ...[
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva actividad'),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _AssignmentCard(
          icon: Icons.campaign_outlined,
          title: 'Jornada deportiva Don Bosco',
          details: 'Viernes · asistir con uniforme deportivo.',
          color: AppColors.youthCoral,
          status: const StatusBadge.success('Publicado'),
        ),
        const SizedBox(height: 12),
        _AssignmentCard(
          icon: Icons.assignment_outlined,
          title: 'Investigación de Ciencias',
          details: 'Entrega: mañana, 8:00 a. m. · documento PDF.',
          color: AppColors.royalBlue,
          status: const StatusBadge.pending('Pendiente'),
        ),
        const SizedBox(height: 12),
        _AssignmentCard(
          icon: Icons.calculate_outlined,
          title: 'Ejercicios de Matemática',
          details: 'Entrega: lunes · páginas 45-47.',
          color: AppColors.violet,
          status: const StatusBadge(label: 'Asignado'),
        ),
        const SizedBox(height: 16),
        const PrototypeNotice(),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showNexoConfirmationDialog(
      context,
      title: 'Diseño de creación listo',
      message:
          'El formulario y la escritura en school_activities se implementan en el milestone del Portal Escolar.',
      confirmLabel: 'Entendido',
      cancelLabel: 'Cerrar',
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String details;
  final Color color;
  final Widget status;

  const _AssignmentCard({
    required this.icon,
    required this.title,
    required this.details,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(details, style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            status,
          ],
        ),
      ),
    );
  }
}
