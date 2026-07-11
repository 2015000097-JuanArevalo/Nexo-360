import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/models/app_user.dart';
import 'package:nexo_360/core/routing/app_router.dart';
import 'package:nexo_360/core/routing/app_routes.dart';

void main() {
  group('AppRouteAccess', () {
    test('student can open personal QR but not event admin', () {
      final student = _user(accountType: 'student', eventRole: 'guest');

      expect(
        AppRouteAccess.canOpen(AppRoutes.studentPermission, student),
        isTrue,
      );
      expect(
        AppRouteAccess.canOpen(AppRoutes.registrationAdmin, student),
        isFalse,
      );
    });

    test('technical staff can create permissions and administer events', () {
      final staff = _user(accountType: 'technical', eventRole: 'none');

      expect(AppRouteAccess.canOpen(AppRoutes.createPermission, staff), isTrue);
      expect(
        AppRouteAccess.canOpen(AppRoutes.registrationAdmin, staff),
        isTrue,
      );
      expect(
        AppRouteAccess.canOpen(AppRoutes.studentPermission, staff),
        isFalse,
      );
    });

    test('organizer can administer registrations', () {
      final organizer = _user(accountType: 'teacher', eventRole: 'organizer');

      expect(
        AppRouteAccess.canOpen(AppRoutes.registrationAdmin, organizer),
        isTrue,
      );
      expect(
        AppRouteAccess.canOpen(AppRoutes.createPermission, organizer),
        isTrue,
      );
    });
  });
}

AppUser _user({required String accountType, required String eventRole}) {
  return AppUser(
    uid: 'uid',
    email: 'demo@nexo360.com',
    displayName: 'Demo',
    accountType: accountType,
    eventRole: eventRole,
    eventPermissions: const [],
    status: 'active',
    schoolCode: 'D-001',
    classId: 'class-10A',
    committeeId: null,
    assignedEventIds: const ['event-demo-01'],
  );
}
