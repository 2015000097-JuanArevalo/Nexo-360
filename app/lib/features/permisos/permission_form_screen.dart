import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class PermissionFormScreen extends StatefulWidget {
  final AppUser user;

  const PermissionFormScreen({super.key, required this.user});

  @override
  State<PermissionFormScreen> createState() => _PermissionFormScreenState();
}

class _PermissionFormScreenState extends State<PermissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _student;

  @override
  Widget build(BuildContext context) {
    final direct = widget.user.isTechnical;
    return PrototypeScreen(
      title: direct ? 'Crear permiso' : 'Solicitar permiso',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeading(
              title: direct ? 'Nuevo permiso estudiantil' : 'Nueva solicitud',
              description: direct
                  ? 'El permiso quedará activo después de guardarlo.'
                  : 'Un técnico deberá aprobar la solicitud.',
              accentColor: AppColors.violet,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _student,
              decoration: const InputDecoration(labelText: 'Estudiante'),
              items: const [
                DropdownMenuItem(value: 's1', child: Text('Ana López · 10A')),
                DropdownMenuItem(
                  value: 's2',
                  child: Text('Carlos Méndez · 10A'),
                ),
              ],
              onChanged: (value) => setState(() => _student = value),
              validator: (value) =>
                  value == null ? 'Selecciona un estudiante.' : null,
            ),
            const SizedBox(height: 14),
            const NexoTextFormField(
              label: 'Motivo',
              icon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            const NexoTextFormField(
              label: 'Destino o actividad',
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: NexoTextFormField(
                    label: 'Inicio',
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NexoTextFormField(
                    label: 'Vencimiento',
                    icon: Icons.timer_off_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      direct
                          ? 'Diseño confirmado: el permiso se guardará en permissions.'
                          : 'Diseño confirmado: se guardará en permission_requests.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: Text(direct ? 'Crear permiso' : 'Enviar solicitud'),
            ),
            const SizedBox(height: 14),
            const PrototypeNotice(),
          ],
        ),
      ),
    );
  }
}
