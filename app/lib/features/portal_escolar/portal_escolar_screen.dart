import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';

class PortalEscolarScreen extends StatelessWidget {
  final AppUser user;

  const PortalEscolarScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final options = <String>[];

    if (user.isTechnical || user.isTeacher) {
      options.addAll([
        'Crear actividad escolar',
        'Editar horarios',
        'Publicar aviso escolar',
        'Revisar asistencia',
        'Gestionar notas',
      ]);
    }

    if (user.isStudent && !user.isTechnical && !user.isTeacher) {
      options.addAll([
        'Ver actividades',
        'Ver horarios',
        'Ver avisos escolares',
        'Ver asistencia',
        'Ver notas',
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Portal Escolar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Usuario: ${user.displayName}'),
          Text('Tipo de cuenta: ${user.accountType}'),
          const SizedBox(height: 24),
          const Text(
            'Opciones disponibles:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...options.map(
            (option) => Card(child: ListTile(title: Text(option))),
          ),
        ],
      ),
    );
  }
}
