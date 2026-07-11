import 'package:go_router/go_router.dart';

import '../../features/eventos/event_registration_screen.dart';
import '../../features/eventos/eventos_screen.dart';
import '../../features/eventos/registration_admin_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/login/login_screen.dart';
import '../../features/permisos/permission_form_screen.dart';
import '../../features/permisos/permisos_screen.dart';
import '../../features/permisos/qr_validation_screen.dart';
import '../../features/permisos/student_qr_screen.dart';
import '../../features/portal_escolar/assignments_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../auth/app_session.dart';
import '../models/app_user.dart';
import '../widgets/nexo_app_shell.dart';
import '../widgets/nexo_ui.dart';
import 'app_routes.dart';

GoRouter createAppRouter(AppSession session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      final publicRoute =
          path == AppRoutes.login || path == AppRoutes.publicRegistration;

      if (session.status == SessionStatus.loading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!session.isAuthenticated) {
        return publicRoute ? null : AppRoutes.login;
      }

      if (path == AppRoutes.splash || path == AppRoutes.login) {
        return AppRoutes.dashboard;
      }

      final user = session.user!;
      if (!AppRouteAccess.canOpen(path, user)) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const NexoSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(session: session),
      ),
      GoRoute(
        path: AppRoutes.publicRegistration,
        builder: (context, state) => const EventRegistrationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => NexoAppShell(
          user: session.user!,
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => HomeScreen(user: session.user!),
          ),
          GoRoute(
            path: AppRoutes.assignments,
            builder: (context, state) => AssignmentsScreen(user: session.user!),
          ),
          GoRoute(
            path: AppRoutes.permissions,
            builder: (context, state) => PermisosScreen(user: session.user!),
          ),
          GoRoute(
            path: AppRoutes.events,
            builder: (context, state) => EventosScreen(user: session.user!),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) =>
                ProfileScreen(user: session.user!, onSignOut: session.signOut),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPermission,
        builder: (context, state) => PermissionFormScreen(user: session.user!),
      ),
      GoRoute(
        path: AppRoutes.studentPermission,
        builder: (context, state) => StudentQrScreen(user: session.user!),
      ),
      GoRoute(
        path: AppRoutes.validatePermission,
        builder: (context, state) => const QrValidationScreen(),
      ),
      GoRoute(
        path: AppRoutes.registrationAdmin,
        builder: (context, state) => const RegistrationAdminScreen(),
      ),
    ],
  );
}

abstract final class AppRouteAccess {
  static bool canOpen(String path, AppUser user) {
    if (!user.isActive) return false;

    return switch (path) {
      AppRoutes.createPermission =>
        user.isTechnical || user.isTeacher || user.isEventOrganizer,
      AppRoutes.studentPermission => user.isStudent,
      AppRoutes.validatePermission => user.isTechnical,
      AppRoutes.registrationAdmin => user.canManageEventRegistrations,
      _ => true,
    };
  }
}
