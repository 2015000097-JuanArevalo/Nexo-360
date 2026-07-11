import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class StudentQrScreen extends StatelessWidget {
  final AppUser user;

  const StudentQrScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Mi permiso',
      child: Column(
        children: [
          const StatusBadge.success('Permiso activo'),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(user.displayName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    user.schoolCode ?? 'Sin código escolar',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 190),
                  ),
                  const SizedBox(height: 18),
                  const Text('Salida autorizada para actividad escolar'),
                  const SizedBox(height: 6),
                  const Text(
                    'Válido hoy · 10:00 a. m. a 12:00 p. m.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const PrototypeNotice(),
        ],
      ),
    );
  }
}
