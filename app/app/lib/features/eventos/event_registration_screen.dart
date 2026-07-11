import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Inscripción pública',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeading(
              title: 'Encuentro Juvenil NEXO 2026',
              description: '18 de julio · Colegio Don Bosco · cupos limitados.',
              accentColor: AppColors.youthCoral,
            ),
            const SizedBox(height: 20),
            NexoTextFormField(
              label: 'Nombre completo',
              icon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa tu nombre.'
                  : null,
            ),
            const SizedBox(height: 14),
            NexoTextFormField(
              label: 'Correo electrónico',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || !value.contains('@')
                  ? 'Ingresa un correo válido.'
                  : null,
            ),
            const SizedBox(height: 14),
            const NexoTextFormField(
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            const NexoTextFormField(
              label: 'Institución u organización',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Adjuntar documento PDF'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await showNexoConfirmationDialog(
                  context,
                  title: 'Confirmar inscripción',
                  message:
                      'Verifica tus datos antes de enviar la inscripción al evento.',
                  confirmLabel: 'Enviar',
                );
              },
              child: const Text('Enviar inscripción'),
            ),
            const SizedBox(height: 14),
            const PrototypeNotice(),
          ],
        ),
      ),
    );
  }
}
