import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../portal_escolar/portal_escolar_screen.dart';
import '../permisos/permisos_screen.dart';
import '../eventos/eventos_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NEXO 360 - ${user.displayName}')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Bienvenido, ${user.displayName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Tipo de cuenta: ${user.accountType}'),
          Text('Rol en eventos: ${user.eventRole}'),
          Text('Código: ${user.schoolCode ?? "Sin código"}'),

          const SizedBox(height: 24),

          _HomeCard(
            title: 'Portal Escolar',
            description: _portalDescription(user),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PortalEscolarScreen(user: user),
                ),
              );
            },
          ),

          _HomeCard(
            title: 'Permisos',
            description: _permissionsDescription(user),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PermisosScreen(user: user)),
              );
            },
          ),

          _HomeCard(
            title: 'Eventos',
            description: _eventsDescription(user),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventosScreen(user: user)),
              );
            },
          ),
        ],
      ),
    );
  }

  String _portalDescription(AppUser user) {
    if (user.isTechnical) return 'Acceso completo al Portal Escolar.';
    if (user.isTeacher)
      return 'Gestiona actividades, horarios y avisos escolares.';
    return 'Consulta actividades, horarios y avisos escolares.';
  }

  String _permissionsDescription(AppUser user) {
    if (user.isTechnical) return 'Administra permisos directamente.';
    if (user.isTeacher || user.isEventOrganizer) {
      return 'Envía solicitudes de creación, edición o eliminación.';
    }
    return 'Consulta tus permisos y verifica QR.';
  }

  String _eventsDescription(AppUser user) {
    if (user.isTechnical) return 'Acceso completo a eventos.';
    if (user.isEventOrganizer) return 'Administra eventos.';
    if (user.isEventCommissioner) return 'Acceso limitado como comisionado.';
    return 'Consulta información e inscripción como invitado.';
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
