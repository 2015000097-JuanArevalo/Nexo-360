import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class RegistrationAdminScreen extends StatelessWidget {
  const RegistrationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Administrar inscripciones',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            title: 'Inscripciones',
            description: 'Encuentro Juvenil NEXO 2026',
            accentColor: AppColors.youthCoral,
          ),
          const SizedBox(height: 18),
          _registration(
            context,
            name: 'María González',
            details: 'Colegio Central · maria@example.com',
            status: const StatusBadge.pending('Pendiente'),
          ),
          const SizedBox(height: 12),
          _registration(
            context,
            name: 'José Ramírez',
            details: 'Instituto Norte · jose@example.com',
            status: const StatusBadge.success('Aprobado'),
          ),
          const SizedBox(height: 16),
          const PrototypeNotice(),
        ],
      ),
    );
  }

  Widget _registration(
    BuildContext context, {
    required String name,
    required String details,
    required Widget status,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFF3E9F8),
                  foregroundColor: AppColors.violet,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        details,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                status,
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Aprobar'),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Reservar')),
                TextButton(onPressed: () {}, child: const Text('Rechazar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
