import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  final AppUser user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: NexoColors.brandGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${user.displayName}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.accountLabel} · ${user.eventRoleLabel}',
                      style: const TextStyle(color: Color(0xFFDCE1FF)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Portal · QR · Eventos',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/nexo_360_icon.png',
                width: 82,
                height: 82,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const PageHeading(
          title: 'Resumen',
          description: 'Información sincronizada en tiempo real según tu rol.',
        ),
        const SizedBox(height: 14),
        _SummaryGrid(user: user),
        const SizedBox(height: 18),
        _DeadlineReminders(user: user),
        if (user.isTechnical) ...[
          const SizedBox(height: 18),
          const _TechnicalDiaryAlerts(),
        ],
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 800 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            final cards = [
              ModuleCard(
                icon: Icons.school_outlined,
                title: 'Portal',
                description:
                    'Actividades, Diario Pedagógico, horario, cursos, notas, avisos y chat.',
                color: NexoColors.royalBlue,
                onTap: () => context.go(AppRoutes.portal),
              ),
              ModuleCard(
                icon: Icons.qr_code_2_outlined,
                title: 'QR',
                description:
                    'Identificación estudiantil, permisos y validación por cámara.',
                color: NexoColors.violet,
                onTap: () => context.go(AppRoutes.qr),
              ),
              ModuleCard(
                icon: Icons.event_outlined,
                title: 'Eventos',
                description:
                    'Eventos escolares, Movimiento Juventud, inscripciones, croquis y operaciones.',
                color: NexoColors.coral,
                onTap: () => context.go(AppRoutes.events),
              ),
              if (user.isTechnical)
                ModuleCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administración técnica',
                  description:
                      'Cuentas, roles, asignaciones, datos iniciales y diagnóstico Firebase.',
                  color: NexoColors.cyan,
                  onTap: () => context.go(AppRoutes.admin),
                ),
            ];
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  cards
                      .map((card) => SizedBox(width: width, child: card))
                      .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final AppUser user;
  const _SummaryGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final summaries = <Widget>[
      _CountTile(
        collection: 'school_activities',
        label: 'Actividades',
        icon: Icons.assignment_outlined,
        color: NexoColors.royalBlue,
        filter: (data) {
          final visible =
              user.isTechnical ||
              user.isTeacher && data['teacherId'] == user.uid ||
              user.isStudent && data['classId'] == user.classId;
          return visible && DateTime.now().isBefore(asDate(data['dueDate']));
        },
      ),
      _CountTile(
        collection: 'permissions',
        label: user.isStudent ? 'Permisos activos' : 'Permisos vigentes',
        icon: Icons.verified_user_outlined,
        color: NexoColors.cyan,
        filter: (data) {
          final visible =
              user.isTechnical ||
              user.isStudent && data['studentId'] == user.uid ||
              user.isTeacher;
          final now = DateTime.now();
          return visible &&
              data['status'] == 'active' &&
              !now.isBefore(asDate(data['validFrom'])) &&
              now.isBefore(asDate(data['validUntil']));
        },
      ),
      if (user.canManageEvents)
        _CountTile(
          collection: 'event_registration_requests',
          label: 'Inscripciones pendientes',
          icon: Icons.how_to_reg_outlined,
          color: NexoColors.coral,
          filter: (data) => data['status'] == 'pending',
        )
      else
        _CountTile(
          collection: 'events',
          label: 'Eventos activos',
          icon: Icons.event_available_outlined,
          color: NexoColors.coral,
          filter:
              (data) => data['status'] == 'active' && data['isPublic'] == true,
        ),
      _CountTile(
        collection: 'school_announcements',
        label: 'Avisos publicados',
        icon: Icons.notifications_none,
        color: NexoColors.violet,
        filter: (_) => true,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (!availableWidth.isFinite || availableWidth <= 0) {
          return const SizedBox.shrink();
        }

        final columns =
            availableWidth >= 900
                ? 4
                : availableWidth >= 420
                ? 2
                : 1;

        const spacing = 10.0;

        final width = (availableWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              summaries
                  .map((tile) => SizedBox(width: width, child: tile))
                  .toList(),
        );
      },
    );
  }
}

class _CountTile extends StatelessWidget {
  final String collection;
  final String label;
  final IconData icon;
  final Color color;
  final bool Function(Map<String, dynamic>) filter;
  const _CountTile({
    required this.collection,
    required this.label,
    required this.icon,
    required this.color,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          final count =
              snapshot.data?.docs.where((doc) => filter(doc.data())).length;
          return Card(
            child: SizedBox(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color),
                    const Spacer(),
                    Text(
                      snapshot.hasError
                          ? '!'
                          : count == null
                          ? '…'
                          : '$count',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: color),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NexoColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _DeadlineReminders extends StatelessWidget {
  final AppUser user;
  const _DeadlineReminders({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('school_activities')
              .snapshots(),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final soon =
            (snapshot.data?.docs ?? const []).where((doc) {
                final data = doc.data();
                final due = asDate(data['dueDate']);
                final visible =
                    user.isTechnical ||
                    user.isTeacher && data['teacherId'] == user.uid ||
                    user.isStudent && data['classId'] == user.classId;
                return visible &&
                    due.isAfter(now) &&
                    due.isBefore(now.add(const Duration(days: 3)));
              }).toList()
              ..sort(
                (a, b) => asDate(
                  a.data()['dueDate'],
                ).compareTo(asDate(b.data()['dueDate'])),
              );
        if (soon.isEmpty) return const SizedBox.shrink();
        return Card(
          color: Theme.of(
            context,
          ).colorScheme.tertiaryContainer.withValues(alpha: .5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alarm_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Recordatorios próximos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...soon
                    .take(4)
                    .map(
                      (doc) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.assignment_late_outlined),
                        title: Text(
                          doc.data()['title'] as String? ?? 'Actividad',
                        ),
                        subtitle: Text(
                          '${doc.data()['courseName'] ?? ''} · ${formatDateTime(doc.data()['dueDate'])}',
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TechnicalDiaryAlerts extends StatelessWidget {
  const _TechnicalDiaryAlerts();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('timetable_periods')
              .where('dayOfWeek', isEqualTo: now.weekday)
              .snapshots(),
      builder: (context, periodSnapshot) {
        if (!periodSnapshot.hasData || periodSnapshot.hasError) {
          return const SizedBox.shrink();
        }
        final endedPeriods =
            periodSnapshot.data!.docs.where((period) {
              final data = period.data();
              if (data['active'] == false) return false;
              final endMinutes = data['endMinutes'] as int? ?? 0;
              final end = DateTime(
                now.year,
                now.month,
                now.day,
                endMinutes ~/ 60,
                endMinutes % 60,
              );
              return now.isAfter(end);
            }).toList();
        if (endedPeriods.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance
                  .collection('pedagogical_diary')
                  .where('dateKey', isEqualTo: dateKey(now))
                  .snapshots(),
          builder: (context, diarySnapshot) {
            final completed =
                (diarySnapshot.data?.docs ??
                        const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                    .where((doc) => doc.data()['completed'] == true)
                    .map((doc) => doc.data()['periodId'] as String? ?? '')
                    .toSet();
            final missing =
                endedPeriods
                    .where((period) => !completed.contains(period.id))
                    .toList();
            if (missing.isEmpty) {
              return Card(
                color: Colors.green.withValues(alpha: .08),
                child: const ListTile(
                  leading: Icon(Icons.task_alt, color: Colors.green),
                  title: Text('Diario Pedagógico al día'),
                  subtitle: Text(
                    'Todos los períodos finalizados de hoy fueron completados.',
                  ),
                ),
              );
            }
            return Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                onTap: () => context.go(AppRoutes.portal),
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(
                  '${missing.length} período(s) finalizado(s) sin completar',
                ),
                subtitle: Text(
                  missing
                      .take(3)
                      .map((period) {
                        final data = period.data();
                        return '${data['classId'] ?? ''} · ${data['courseName'] ?? data['courseId'] ?? 'Curso'}';
                      })
                      .join(' | '),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
