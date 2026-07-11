import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/app_user.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';
import '../eventos/event_registration_screen.dart';
import '../eventos/eventos_screen.dart';
import '../login/login_screen.dart';
import '../permisos/permission_form_screen.dart';
import '../permisos/permisos_screen.dart';
import '../permisos/qr_validation_screen.dart';
import '../permisos/student_qr_screen.dart';
import '../portal_escolar/activity_board_screen.dart';
import '../portal_escolar/portal_escolar_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
    NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Portal'),
    NavigationDestination(icon: Icon(Icons.qr_code_2_outlined), label: 'Permisos'),
    NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Eventos'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
  ];

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _page() {
    return switch (_selectedIndex) {
      0 => _DashboardView(user: widget.user, selectSection: _selectSection),
      1 => PortalEscolarScreen(user: widget.user),
      2 => PermisosScreen(user: widget.user),
      3 => EventosScreen(user: widget.user),
      _ => ProfileScreen(user: widget.user, onSignOut: _signOut),
    };
  }

  void _selectSection(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: _page(),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const NexoLogo(compact: true),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Text(
                widget.user.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Perfil y ajustes',
            onPressed: () => _selectSection(4),
            icon: const CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.white,
                  selectedIndex: _selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: _selectSection,
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: item.icon,
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: _destinations,
              onDestinationSelected: _selectSection,
            ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final AppUser user;
  final ValueChanged<int> selectSection;

  const _DashboardView({required this.user, required this.selectSection});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      NexoModuleCard(
        icon: Icons.campaign_outlined,
        title: 'Avisos y actividades',
        description: user.isStudent
            ? 'Consulta tareas, fechas y anuncios escolares.'
            : 'Publica y administra avisos y actividades escolares.',
        onTap: () => _open(context, ActivityBoardScreen(user: user)),
      ),
      if (user.isStudent)
        NexoModuleCard(
          icon: Icons.qr_code_2,
          title: 'Mi permiso y QR',
          description: 'Consulta el estado de tu permiso y presenta tu código.',
          badge: 'Activo',
          onTap: () => _open(context, StudentQrScreen(user: user)),
        )
      else
        NexoModuleCard(
          icon: Icons.add_task_outlined,
          title: user.isTechnical ? 'Crear permiso' : 'Solicitar permiso',
          description: user.isTechnical
              ? 'Registra un permiso estudiantil directamente.'
              : 'Envía una solicitud para revisión técnica.',
          onTap: () => _open(context, PermissionFormScreen(user: user)),
        ),
      NexoModuleCard(
        icon: Icons.qr_code_scanner,
        title: 'Consultar QR',
        description: 'Revisa si el permiso presentado es válido o expiró.',
        onTap: () => _open(context, const QrValidationScreen()),
      ),
      NexoModuleCard(
        icon: Icons.how_to_reg_outlined,
        title: 'Inscripción a eventos',
        description: 'Consulta el evento activo y completa una inscripción.',
        onTap: () => _open(context, const EventRegistrationScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Hola, ${user.displayName}',
          description: _roleDescription(user),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cards.map((card) => SizedBox(width: width, child: card)).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Secciones principales', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => selectSection(1),
              icon: const Icon(Icons.school_outlined),
              label: const Text('Portal Escolar'),
            ),
            OutlinedButton.icon(
              onPressed: () => selectSection(2),
              icon: const Icon(Icons.qr_code_2_outlined),
              label: const Text('Permisos'),
            ),
            OutlinedButton.icon(
              onPressed: () => selectSection(3),
              icon: const Icon(Icons.event_outlined),
              label: const Text('Eventos'),
            ),
          ],
        ),
      ],
    );
  }

  String _roleDescription(AppUser user) {
    if (user.isTechnical) return 'Panel técnico · administración general del prototipo';
    if (user.isTeacher) return 'Panel docente · gestión escolar y solicitudes';
    return 'Panel estudiantil · información, permisos y eventos';
  }
}
