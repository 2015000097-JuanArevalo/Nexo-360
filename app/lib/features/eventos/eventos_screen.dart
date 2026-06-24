import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';

class EventosScreen extends StatelessWidget {
  final AppUser user;

  const EventosScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final options = <String>[];

    if (user.isTechnical || user.isEventOrganizer) {
      options.addAll([
        'Crear evento',
        'Editar evento',
        'Eliminar evento',
        'Publicar aviso de evento',
        'Revisar inscripciones',
        'Gestionar inventario',
        'Gestionar ubicaciones',
        'Asignar comisionados',
      ]);
    } else if (user.isEventCommissioner) {
      if (user.hasEventPermission('view_event_announcements')) {
        options.add('Ver avisos de evento');
      }
      if (user.hasEventPermission('view_assigned_event')) {
        options.add('Ver evento asignado');
      }
      if (user.hasEventPermission('check_in')) {
        options.add('Realizar check-in');
      }
      if (user.hasEventPermission('request_inventory')) {
        options.add('Solicitar inventario');
      }
      if (user.hasEventPermission('view_inventory')) {
        options.add('Ver inventario asignado');
      }
      if (user.hasEventPermission('view_map')) {
        options.add('Ver mapa/croquis');
      }
      if (user.hasEventPermission('create_event_message')) {
        options.add('Crear mensaje de evento');
      }
    } else {
      options.addAll([
        'Ver información del evento',
        'Enviar formulario de inscripción',
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
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
