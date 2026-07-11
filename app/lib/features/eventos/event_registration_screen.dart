import 'package:flutter/material.dart';

import '../../core/widgets/nexo_ui.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
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
              description: '18 de julio · Colegio NEXO · cupos limitados.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa tu nombre.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              validator: (value) => value == null || !value.contains('@')
                  ? 'Ingresa un correo válido.'
                  : null,
            ),
            const SizedBox(height: 14),
            const TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(labelText: 'Institución u organización'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Adjuntar documento PDF'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Diseño confirmado'),
                    content: const Text(
                      'En el siguiente milestone, esta acción creará una inscripción con estado pending.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
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
