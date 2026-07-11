import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/models/school_announcement.dart';
import '../../core/models/school_assignment.dart';
import '../../core/services/school_portal_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';
import 'assignment_detail_screen.dart';
import 'create_assignment_sheet.dart';

class AssignmentsScreen extends StatefulWidget {
  final AppUser user;
  final SchoolPortalService? service;

  const AssignmentsScreen({super.key, required this.user, this.service});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late final SchoolPortalService _service;
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SchoolPortalService();
  }

  Future<void> _createAssignment() async {
    final created = await showCreateAssignmentSheet(
      context,
      user: widget.user,
      service: _service,
    );
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actividad creada correctamente.')),
    );
  }

  Future<void> _seedAnnouncements() async {
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Crear avisos de demostración',
      message: 'Se crearán tres avisos en school_announcements.',
      confirmLabel: 'Crear avisos',
    );
    if (!confirmed || !mounted) return;

    setState(() => _seeding = true);
    try {
      await _service.seedSampleAnnouncements(widget.user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avisos de demostración creados.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron crear los avisos.')),
      );
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Portal Escolar',
          description: widget.user.canPublishSchoolContent
              ? 'Publica avisos y actividades para estudiantes.'
              : 'Consulta avisos, actividades y fechas de entrega.',
          accentColor: AppColors.royalBlue,
        ),
        const SizedBox(height: 20),
        _sectionTitle(
          context,
          icon: Icons.campaign_outlined,
          title: 'Avisos escolares',
          color: AppColors.youthCoral,
        ),
        const SizedBox(height: 12),
        _announcements(),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                context,
                icon: Icons.assignment_outlined,
                title: 'Actividades y tareas',
                color: AppColors.royalBlue,
              ),
            ),
            if (widget.user.canPublishSchoolContent)
              FilledButton.icon(
                onPressed: _createAssignment,
                icon: const Icon(Icons.add),
                label: const Text('Nueva actividad'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _assignments(),
      ],
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 9),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _announcements() {
    return StreamBuilder<List<SchoolAnnouncement>>(
      stream: _service.watchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: AppLoadingIndicator(message: 'Cargando avisos...'),
          );
        }
        if (snapshot.hasError) {
          return const AppErrorMessage(
            message: 'No se pudieron cargar los avisos escolares.',
          );
        }

        final announcements = snapshot.data ?? const <SchoolAnnouncement>[];
        if (announcements.isEmpty) {
          return AppEmptyState(
            icon: Icons.campaign_outlined,
            title: 'No hay avisos',
            description: 'Todavía no se han publicado avisos escolares.',
            action: widget.user.canPublishSchoolContent
                ? FilledButton.icon(
                    onPressed: _seeding ? null : _seedAnnouncements,
                    icon: _seeding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Crear datos de demostración'),
                  )
                : null,
          );
        }

        return SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: announcements.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return SizedBox(
                width: 310,
                child: _AnnouncementCard(announcement: announcement),
              );
            },
          ),
        );
      },
    );
  }

  Widget _assignments() {
    return StreamBuilder<List<SchoolAssignment>>(
      stream: _service.watchAssignments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 190,
            child: AppLoadingIndicator(message: 'Cargando actividades...'),
          );
        }
        if (snapshot.hasError) {
          return const AppErrorMessage(
            message: 'Firebase no pudo cargar las actividades.',
          );
        }

        final assignments = snapshot.data ?? const <SchoolAssignment>[];
        if (assignments.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No hay actividades',
            description: widget.user.canPublishSchoolContent
                ? 'Usa “Nueva actividad” para publicar la primera.'
                : 'Tu docente todavía no ha publicado actividades.',
          );
        }

        return Column(
          children: assignments
              .map(
                (assignment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AssignmentCard(
                    assignment: assignment,
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AssignmentDetailScreen(assignment: assignment),
                          ),
                        ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final SchoolAnnouncement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.campaign_outlined,
                  color: AppColors.youthCoral,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement.course,
                    style: const TextStyle(
                      color: AppColors.youthCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              announcement.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                announcement.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            Text(
              '${announcement.authorName} · ${formatSchoolDate(announcement.createdAt)}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final SchoolAssignment assignment;
  final VoidCallback onTap;

  const _AssignmentCard({required this.assignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${assignment.course} · Entrega ${formatSchoolDateTime(assignment.dueDate)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (assignment.hasAttachment) ...[
                const SizedBox(width: 8),
                const Icon(Icons.attach_file, color: AppColors.violet),
              ],
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
