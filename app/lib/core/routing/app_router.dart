import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/technical_admin_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/events/events_hub_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/portal/portal_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/qr/qr_hub_screen.dart';
import '../auth/app_session.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import 'app_routes.dart';

GoRouter createAppRouter(AppSession session, ThemeController themeController) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      if (session.status == SessionStatus.loading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (session.status == SessionStatus.signedOut) {
        return path == AppRoutes.login ? null : AppRoutes.login;
      }
      if (session.status == SessionStatus.blocked) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (path == AppRoutes.splash || path == AppRoutes.login) return AppRoutes.dashboard;
      if (path == AppRoutes.admin && session.user?.isTechnical != true) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => session.status == SessionStatus.blocked
            ? _BlockedScreen(session: session)
            : const SplashScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginScreen(session: session)),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          user: session.user!,
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (context, state) => DashboardScreen(user: session.user!)),
          GoRoute(path: AppRoutes.portal, builder: (context, state) => PortalScreen(user: session.user!)),
          GoRoute(path: AppRoutes.qr, builder: (context, state) => QrHubScreen(user: session.user!)),
          GoRoute(path: AppRoutes.events, builder: (context, state) => EventsHubScreen(user: session.user!)),
          GoRoute(path: AppRoutes.admin, builder: (context, state) => TechnicalAdminScreen(user: session.user!)),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => ProfileScreen(
              user: session.user!,
              themeController: themeController,
              onSignOut: session.signOut,
              onProfileChanged: session.refreshProfile,
            ),
          ),
        ],
      ),
    ],
  );
}

class _BlockedScreen extends StatelessWidget {
  final AppSession session;
  const _BlockedScreen({required this.session});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NexoLogo(),
                    const SizedBox(height: 18),
                    const Icon(Icons.lock_person_outlined, size: 52),
                    const SizedBox(height: 10),
                    Text('Cuenta sin acceso', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(session.error ?? 'La cuenta no tiene un perfil activo.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: session.signOut, icon: const Icon(Icons.logout), label: const Text('Volver al inicio de sesión')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
