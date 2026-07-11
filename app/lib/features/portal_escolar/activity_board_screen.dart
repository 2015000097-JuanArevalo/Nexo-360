import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class ActivityBoardScreen extends StatelessWidget {
  final AppUser user;

  const ActivityBoardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Avisos y actividades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            title: 'Clase 10A',
            description: 'Contenido de demostración del Portal Escolar.',
          ),
          const SizedBox(height: 16),
          if (user.isTechnical || user.isTeacher)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _showEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva actividad'),
              ),
            ),
          if (user.isTechnical || user.isTeacher) const SizedBox(height: 16),
          _item(
            context,
            icon: Icons.campaign_outlined,
            title: 'Aviso: jornada deportiva',
            subtitle: 'Viernes · asistir con uniforme deportivo.',
            badge: const StatusBadge.success('Publicado'),
          ),
          const SizedBox(height: 12),
          _item(
            context,
            icon: Icons.assignment_outlined,
            title: 'Investigación de Ciencias',
            subtitle: 'Entrega: mañana, 8:00 a. m. · documento PDF.',
            badge: const StatusBadge.pending('Pendiente'),
          ),
          const SizedBox(height: 16),
          const PrototypeNotice(),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget badge,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            badge,
          ],
        ),
      ),
    );
  }

  void _showEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nueva actividad', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Título')),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Instrucciones'),
            ),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Fecha de entrega')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Guardar diseño'),
            ),
          ],
        ),
      ),
    );
  }
}
