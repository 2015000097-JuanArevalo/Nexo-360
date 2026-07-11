import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/app_user.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import 'nexo_ui.dart';

class NexoAppShell extends StatelessWidget {
  final AppUser user;
  final String currentPath;
  final Widget child;

  const NexoAppShell({
    super.key,
    required this.user,
    required this.currentPath,
    required this.child,
  });

  static const _destinations = [
    _ShellDestination(
      label: 'Inicio',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: AppRoutes.dashboard,
    ),
    _ShellDestination(
      label: 'Actividades',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      path: AppRoutes.assignments,
    ),
    _ShellDestination(
      label: 'Permisos',
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2,
      path: AppRoutes.permissions,
    ),
    _ShellDestination(
      label: 'Eventos',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      path: AppRoutes.events,
    ),
    _ShellDestination(
      label: 'Perfil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      path: AppRoutes.profile,
    ),
  ];

  int get _selectedIndex {
    if (currentPath.startsWith(AppRoutes.assignments)) return 1;
    if (currentPath.startsWith(AppRoutes.permissions)) return 2;
    if (currentPath.startsWith(AppRoutes.events)) return 3;
    if (currentPath.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: child,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const NexoLogo(compact: true),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 560)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user.accountLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBFC7EA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            tooltip: 'Perfil y ajustes',
            onPressed: () => context.go(AppRoutes.profile),
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.youthGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                Container(
                  color: AppColors.navy,
                  child: NavigationRail(
                    backgroundColor: AppColors.navy,
                    indicatorColor: const Color(0xFF232A78),
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.cyan,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: Color(0xFF9AA4D3),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF9AA4D3),
                    ),
                    selectedIndex: _selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (index) {
                      context.go(_destinations[index].path);
                    },
                    destinations: _destinations
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                context.go(_destinations[index].path);
              },
              destinations: _destinations
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ShellDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}
