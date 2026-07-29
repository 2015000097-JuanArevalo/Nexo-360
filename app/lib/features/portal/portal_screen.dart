import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import 'activities_screen.dart';
import 'announcements_screen.dart';
import 'courses_screen.dart';
import 'diary_screen.dart';
import 'grades_screen.dart';
import 'school_chat_screen.dart';
import 'timetable_screen.dart';

class PortalScreen extends StatelessWidget {
  final AppUser user;
  const PortalScreen({super.key, required this.user});

  void open(BuildContext context, String title, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      _PortalModule(
        Icons.assignment_outlined,
        'Actividades',
        'Actividades agrupadas por fecha, enlaces, entregas, prórrogas y entregas tardías.',
        NexoColors.royalBlue,
        () => open(context, 'Actividades', ActivitiesScreen(user: user)),
      ),
      _PortalModule(
        Icons.menu_book_outlined,
        'Diario Pedagógico',
        'Entrada rápida a los períodos del día, asistencia, contenido visto, tareas y observaciones.',
        NexoColors.violet,
        () => open(context, 'Diario Pedagógico', DiaryScreen(user: user)),
        badge: 'Hoy',
      ),
      _PortalModule(
        Icons.calendar_view_week_outlined,
        'Horario',
        'Horario semanal administrado por técnicos y calendario con todas las actividades.',
        NexoColors.cyan,
        () => open(context, 'Horario', TimetableScreen(user: user)),
      ),
      _PortalModule(
        Icons.menu_book_rounded,
        'Cursos y clases',
        'Cursos asignados, secciones, docentes y carpeta de material por enlaces.',
        NexoColors.royalBlue,
        () => open(context, 'Cursos y clases', CoursesScreen(user: user)),
      ),
      _PortalModule(
        Icons.grade_outlined,
        'Notas',
        'Zona, parciales, examen final, bimestres, promedio individual y general.',
        NexoColors.violet,
        () => open(context, 'Notas', GradesScreen(user: user)),
      ),
      _PortalModule(
        Icons.notifications_none,
        'Avisos',
        'Avisos generales, por curso o sección, separados entre leídos y no leídos.',
        NexoColors.coral,
        () => open(context, 'Avisos', AnnouncementsScreen(user: user)),
      ),
      _PortalModule(
        Icons.forum_outlined,
        'Chat escolar',
        'Conversación en tiempo real de la sección y de los cursos.',
        NexoColors.cyan,
        () => open(context, 'Chat escolar', SchoolChatScreen(user: user)),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Portal',
          description: 'Toda la administración académica en un solo apartado.',
        ),
        const SizedBox(height: 18),
        Card(
          child: InkWell(
            onTap: () => open(context, 'Diario Pedagógico', DiaryScreen(user: user)),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: NexoColors.brandGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.play_arrow, color: Colors.white)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Abrir el Diario Pedagógico de hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Acceso rápido sin buscar manualmente en el horario.', style: TextStyle(color: Color(0xFFDCE1FF))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 820 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: modules
                  .map((module) => SizedBox(
                        width: width,
                        child: ModuleCard(
                          icon: module.icon,
                          title: module.title,
                          description: module.description,
                          color: module.color,
                          onTap: module.onTap,
                          badge: module.badge,
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PortalModule {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  const _PortalModule(this.icon, this.title, this.description, this.color, this.onTap, {this.badge});
}
