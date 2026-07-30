import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/app_user.dart';
import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class AppShell extends StatelessWidget {
  final AppUser user;
  final String currentPath;
  final Widget child;
  const AppShell({
    super.key,
    required this.user,
    required this.currentPath,
    required this.child,
  });

  List<_Destination> get destinations => [
    const _Destination('Inicio', Icons.dashboard_outlined, AppRoutes.dashboard),
    const _Destination('Portal', Icons.school_outlined, AppRoutes.portal),
    const _Destination('QR', Icons.qr_code_2_outlined, AppRoutes.qr),
    const _Destination('Eventos', Icons.event_outlined, AppRoutes.events),
    if (user.isTechnical)
      const _Destination(
        'Administración',
        Icons.admin_panel_settings_outlined,
        AppRoutes.admin,
      ),
    const _Destination('Usuario', Icons.person_outline, AppRoutes.profile),
  ];

  int get selectedIndex {
    final index = destinations.indexWhere(
      (destination) =>
          destination.path == AppRoutes.dashboard
              ? currentPath == AppRoutes.dashboard
              : currentPath.startsWith(destination.path),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 950;
    final content = SafeArea(child: child);

    return Scaffold(
      appBar: AppBar(
        title: const NexoLogo(compact: true),
        actions: [
          if (MediaQuery.sizeOf(context).width > 600)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.accountLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFC7CDED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            tooltip: 'Perfil y temas',
            onPressed: () => context.go(AppRoutes.profile),
            icon: const CircleAvatar(
              backgroundColor: NexoColors.violet,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          wide
              ? Row(
                children: [
                  NavigationRail(
                    backgroundColor: NexoColors.navy,
                    selectedIndex: selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(
                      color: NexoColors.cyan,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: Color(0xFF9AA4D3),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF9AA4D3),
                    ),
                    onDestinationSelected:
                        (index) => context.go(destinations[index].path),
                    destinations:
                        destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: Icon(destination.icon),
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                  ),
                  Expanded(child: content),
                ],
              )
              : content,
      bottomNavigationBar:
          wide
              ? null
              : NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected:
                    (index) => context.go(destinations[index].path),
                destinations:
                    destinations
                        .map(
                          (destination) => NavigationDestination(
                            icon: Icon(destination.icon),
                            label: destination.label,
                          ),
                        )
                        .toList(),
              ),
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final String path;
  const _Destination(this.label, this.icon, this.path);
}
