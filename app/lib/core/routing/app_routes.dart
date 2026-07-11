abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const assignments = '/assignments';
  static const permissions = '/permissions';
  static const createPermission = '/permissions/create';
  static const studentPermission = '/permissions/student';
  static const validatePermission = '/permissions/validate';
  static const pendingPermissionRequests = '/permissions/requests';
  static const events = '/events';
  static const createEvent = '/events/create';
  static const publicRegistration = '/events/register';
  static const registrationStatus = '/events/status';
  static const registrationAdmin = '/events/admin';
  static const presentationSetup = '/presentation/setup';
  static const profile = '/profile';

  static String registrationStatusFor(String registrationId) {
    return '$registrationStatus/$registrationId';
  }
}
