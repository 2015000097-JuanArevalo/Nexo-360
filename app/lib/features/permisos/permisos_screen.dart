import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';

class PermisosScreen extends StatelessWidget {
  final AppUser user;

  const PermisosScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final options = <String>[];

    if (user.isTechnical) {
      options.addAll([
        'Crear permiso directamente',
        'Editar permiso directamente',
        'Eliminar permiso directamente',
        'Aprobar solicitudes de permisos',
        'Denegar solicitudes de permisos',
        'Leer/verificar QR',
      ]);
    } else {
      if (user.isTeacher || user.isEventOrganizer) {
        options.addAll([
          'Solicitar creación de permiso',
          'Solicitar edición de permiso',
          'Solicitar eliminación de permiso',
        ]);
      }

      if (user.isStudent) {
        options.addAll(['Ver mis permisos', 'Mostrar mi QR']);
      }

      options.add('Leer/verificar QR de estudiante');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Permisos')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Usuario: ${user.displayName}'),
          Text('Tipo de cuenta: ${user.accountType}'),
          Text('Rol en eventos: ${user.eventRole}'),
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
