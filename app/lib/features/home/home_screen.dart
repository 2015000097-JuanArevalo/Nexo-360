import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/dashboard_summary_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final cards = _cardsFor(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
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
                    const SizedBox(height: 6),
                    Text(
                      '${user.accountLabel} · ${user.eventRoleLabel}',
                      style: const TextStyle(color: Color(0xFFDCE1FF)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Portal Escolar · Permisos · Movimiento Juventud',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.hub_outlined,
                size: 64,
                color: Color(0x99FFFFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PageHeading(
          title: 'Accesos para ${user.accountLabel.toLowerCase()}',
          description: _roleDescription(user),
        ),
        const SizedBox(height: 18),
        _DashboardSummaries(user: user),
        const SizedBox(height: 18),
        if (user.isStudent) ...[
          const _AcademicPreview(),
          const SizedBox(height: 18),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      child: NexoModuleCard(
                        icon: card.icon,
                        title: card.title,
                        description: card.description,
                        accentColor: card.color,
                        badge: card.badge,
                        badgeTone: card.badgeTone,
                        onTap: () => context.push(card.path),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 22),
        const _PrototypeModules(),
      ],
    );
  }

  List<_DashboardItem> _cardsFor(AppUser user) {
    final items = <_DashboardItem>[
      const _DashboardItem(
        icon: Icons.assignment_outlined,
        title: 'Avisos y actividades',
        description: 'Consulta el trabajo escolar y los anuncios de tu clase.',
        path: AppRoutes.assignments,
        color: AppColors.royalBlue,
      ),
    ];

    if (user.isStudent) {
      items.add(
        const _DashboardItem(
          icon: Icons.qr_code_2,
          title: 'Mi permiso y QR',
          description: 'Consulta la vigencia y presenta tu código personal.',
          path: AppRoutes.studentPermission,
          color: AppColors.cyan,
          badge: 'Estudiante',
          badgeTone: StatusTone.success,
        ),
      );
    }

    if (user.canCreatePermission || user.canRequestPermission) {
      items.add(
        _DashboardItem(
          icon: Icons.add_task_outlined,
          title: user.canCreatePermission
              ? 'Crear permiso'
              : 'Solicitar permiso',
          description: user.canCreatePermission
              ? 'Registra un permiso estudiantil directamente.'
              : 'Envía una solicitud para revisión del personal técnico.',
          path: AppRoutes.createPermission,
          color: AppColors.violet,
        ),
      );
    }

    if (user.isTechnical || user.isTeacher) {
      items.add(
        const _DashboardItem(
          icon: Icons.qr_code_scanner,
          title: 'Validar QR',
          description: 'Verifica un permiso por cámara o código manual.',
          path: AppRoutes.validatePermission,
          color: AppColors.primary,
        ),
      );
    }

    if (user.isTechnical) {
      items.add(
        const _DashboardItem(
          icon: Icons.approval_outlined,
          title: 'Solicitudes pendientes',
          description: 'Aprueba o deniega solicitudes de permisos.',
          path: AppRoutes.pendingPermissionRequests,
          color: AppColors.youthCoral,
          badge: 'Revisión técnica',
          badgeTone: StatusTone.pending,
        ),
      );
      items.add(
        const _DashboardItem(
          icon: Icons.auto_awesome_outlined,
          title: 'Preparar presentación',
          description: 'Crea y refresca los datos integrados de demostración.',
          path: AppRoutes.presentationSetup,
          color: AppColors.violet,
          badge: 'Solo técnico',
        ),
      );
    }

    items.add(
      const _DashboardItem(
        icon: Icons.event_available_outlined,
        title: 'Eventos y registro',
        description: 'Consulta Movimiento Juventud y completa una inscripción.',
        path: AppRoutes.events,
        color: AppColors.youthCoral,
      ),
    );

    if (user.canCreateEvents) {
      items.add(
        const _DashboardItem(
          icon: Icons.add_circle_outline,
          title: 'Crear evento',
          description: 'Publica un nuevo evento y abre sus inscripciones.',
          path: AppRoutes.createEvent,
          color: AppColors.youthCoral,
          badge: 'Organización',
        ),
      );
    }

    if (user.canManageEventRegistrations) {
      items.add(
        const _DashboardItem(
          icon: Icons.people_alt_outlined,
          title: 'Administrar inscripciones',
          description: 'Revisa participantes pendientes y aprobados.',
          path: AppRoutes.registrationAdmin,
          color: AppColors.violet,
          badge: 'Organización',
        ),
      );
    }

    return items;
  }

  String _roleDescription(AppUser user) {
    if (user.isTechnical) {
      return 'Administración, creación de permisos y consulta de códigos QR.';
    }
    if (user.isTeacher && user.isEventOrganizer) {
      return 'Gestión escolar, solicitudes de permisos y administración de eventos.';
    }
    if (user.isTeacher) {
      return 'Actividades escolares, solicitudes de permisos y consulta de QR.';
    }
    if (user.isEventOrganizer) {
      return 'Consulta estudiantil y herramientas de organización de eventos.';
    }
    return 'Actividades escolares, permiso personal e información de eventos.';
  }
}

class _DashboardSummaries extends StatefulWidget {
  final AppUser user;

  const _DashboardSummaries({required this.user});

  @override
  State<_DashboardSummaries> createState() => _DashboardSummariesState();
}

class _DashboardSummariesState extends State<_DashboardSummaries> {
  late final DashboardSummaryService _service;

  @override
  void initState() {
    super.initState();
    _service = DashboardSummaryService();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: width,
              child: StreamBuilder<int>(
                stream: _service.watchPendingAssignments(),
                builder: (context, snapshot) => _SummaryTile(
                  icon: Icons.assignment_late_outlined,
                  label: 'Tareas pendientes',
                  value: _numberValue(snapshot),
                  color: AppColors.royalBlue,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: StreamBuilder<int?>(
                stream: _service.watchActivePermissions(widget.user),
                builder: (context, snapshot) => _SummaryTile(
                  icon: Icons.verified_user_outlined,
                  label: widget.user.isTechnical || widget.user.isStudent
                      ? 'Permisos activos'
                      : 'Solicitudes propias',
                  value: _nullableNumberValue(snapshot),
                  color: AppColors.cyan,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: StreamBuilder<int?>(
                stream: _service.watchPendingRegistrations(widget.user),
                builder: (context, snapshot) => _SummaryTile(
                  icon: Icons.people_alt_outlined,
                  label: 'Registros pendientes',
                  value: _nullableNumberValue(snapshot),
                  color: AppColors.youthCoral,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: StreamBuilder<String?>(
                stream: _service.watchLatestAnnouncement(),
                builder: (context, snapshot) => _SummaryTile(
                  icon: Icons.campaign_outlined,
                  label: 'Último aviso',
                  value: snapshot.hasError
                      ? 'Error'
                      : snapshot.connectionState == ConnectionState.waiting
                      ? '...'
                      : snapshot.data ?? 'Sin avisos',
                  color: AppColors.violet,
                  compactValue: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _numberValue(AsyncSnapshot<int> snapshot) {
    if (snapshot.hasError) return 'Error';
    if (snapshot.connectionState == ConnectionState.waiting) return '...';
    return '${snapshot.data ?? 0}';
  }

  String _nullableNumberValue(AsyncSnapshot<int?> snapshot) {
    if (snapshot.hasError) return 'Error';
    if (snapshot.connectionState == ConnectionState.waiting) return '...';
    final value = snapshot.data;
    return value == null ? '—' : '$value';
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compactValue;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            maxLines: compactValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontSize: compactValue ? 15 : 24,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PrototypeModules extends StatelessWidget {
  const _PrototypeModules();

  @override
  Widget build(BuildContext context) {
    const modules = [
      ('Inventario', Icons.inventory_2_outlined),
      ('Mapa en vivo', Icons.map_outlined),
      ('Comunicación de comités', Icons.forum_outlined),
      ('Calificaciones', Icons.grade_outlined),
      ('Asistencia', Icons.fact_check_outlined),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Módulos secundarios',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const StatusBadge(label: 'Prototipos'),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Se muestran como alcance futuro y no abren flujos incompletos.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: modules
                  .map(
                    (module) => Chip(
                      avatar: Icon(module.$2, size: 18),
                      label: Text('${module.$1} · Prototipo'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicPreview extends StatelessWidget {
  const _AcademicPreview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen académico',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Datos de demostración · gestión detallada próximamente',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _AcademicMetric(
                    icon: Icons.grade_outlined,
                    label: 'Promedio actual',
                    value: '87.5',
                    color: AppColors.violet,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _AcademicMetric(
                    icon: Icons.fact_check_outlined,
                    label: 'Asistencia',
                    value: '94%',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AcademicMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: color),
                ),
                Text(label, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;
  final String description;
  final String path;
  final Color color;
  final String? badge;
  final StatusTone badgeTone;

  const _DashboardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
    required this.color,
    this.badge,
    this.badgeTone = StatusTone.info,
  });
}
