import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/school_assignment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final SchoolAssignment assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Detalle de actividad',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(
            title: assignment.title,
            description: assignment.course,
            accentColor: AppColors.royalBlue,
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Fecha de entrega',
                    value: formatSchoolDateTime(assignment.dueDate),
                  ),
                  const Divider(height: 28),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Docente',
                    value: assignment.teacherName,
                  ),
                  const Divider(height: 28),
                  Text(
                    'Instrucciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description.isEmpty
                        ? 'Sin instrucciones adicionales.'
                        : assignment.description,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (assignment.hasAttachment)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material adjunto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      assignment.attachmentUrl!,
                      style: const TextStyle(color: AppColors.royalBlue),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: assignment.attachmentUrl!),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado.')),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copiar enlace'),
                    ),
                  ],
                ),
              ),
            )
          else
            const AppEmptyState(
              icon: Icons.link_off_outlined,
              title: 'Sin material adjunto',
              description: 'Esta actividad no incluye enlaces adicionales.',
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.royalBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
