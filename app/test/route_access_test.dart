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
      expect(AppRouteAccess.canOpen(AppRoutes.createEvent, staff), isTrue);
      expect(
        AppRouteAccess.canOpen(AppRoutes.presentationSetup, staff),
        isTrue,
      );
      expect(
        AppRouteAccess.canOpen(AppRoutes.studentPermission, staff),
        isFalse,
      );
    });

    test(
      'teacher organizer can create events and administer registrations',
      () {
        final organizer = _user(accountType: 'teacher', eventRole: 'organizer');

        expect(
          AppRouteAccess.canOpen(AppRoutes.registrationAdmin, organizer),
          isTrue,
        );
        expect(
          AppRouteAccess.canOpen(AppRoutes.createPermission, organizer),
          isTrue,
        );
        expect(
          AppRouteAccess.canOpen(AppRoutes.createEvent, organizer),
          isTrue,
        );
      },
    );

    test(
      'student organizer can create events and administer registrations',
      () {
        final organizer = _user(accountType: 'student', eventRole: 'organizer');

        expect(
          AppRouteAccess.canOpen(AppRoutes.createEvent, organizer),
          isTrue,
        );
        expect(
          AppRouteAccess.canOpen(AppRoutes.registrationAdmin, organizer),
          isTrue,
        );
      },
    );

    test('teacher and student guests cannot create events', () {
      final teacher = _user(accountType: 'teacher', eventRole: 'guest');
      final student = _user(accountType: 'student', eventRole: 'guest');

      expect(AppRouteAccess.canOpen(AppRoutes.createEvent, teacher), isFalse);
      expect(AppRouteAccess.canOpen(AppRoutes.createEvent, student), isFalse);
      expect(
        AppRouteAccess.canOpen(AppRoutes.presentationSetup, teacher),
        isFalse,
      );
    });

    test('inactive organizer cannot create events', () {
      final organizer = _user(
        accountType: 'student',
        eventRole: 'organizer',
        status: 'inactive',
      );

      expect(AppRouteAccess.canOpen(AppRoutes.createEvent, organizer), isFalse);
    });
  });
}

AppUser _user({
  required String accountType,
  required String eventRole,
  String status = 'active',
}) {
  return AppUser(
    uid: 'uid',
    email: 'demo@nexo360.com',
    displayName: 'Demo',
    accountType: accountType,
    eventRole: eventRole,
    eventPermissions: const [],
    status: status,
    schoolCode: 'D-001',
    classId: 'class-10A',
    committeeId: null,
    assignedEventIds: const ['event-demo-01'],
  );
}
