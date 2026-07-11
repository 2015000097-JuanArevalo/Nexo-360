import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/models/permission_record.dart';
import 'package:nexo_360/core/services/permission_validator.dart';
import 'package:nexo_360/core/utils/permission_qr_payload.dart';

void main() {
  group('Permission QR payload', () {
    test('encodes and decodes JSON and manual formats', () {
      const payload = PermissionQrPayload(
        permissionId: 'permission-01',
        qrToken: 'secure-token-1234567890123456',
      );

      expect(
        PermissionQrPayload.tryParse(payload.encode())?.permissionId,
        'permission-01',
      );
      expect(
        PermissionQrPayload.tryParse(payload.encodeManual())?.qrToken,
        'secure-token-1234567890123456',
      );
    });
  });

  group('Permission validation', () {
    final now = DateTime(2026, 7, 10, 12);

    test('returns valid inside the authorized period', () {
      final result = PermissionValidator.evaluate(
        permission: _permission(
          validFrom: now.subtract(const Duration(hours: 1)),
          validUntil: now.add(const Duration(hours: 1)),
        ),
        receivedToken: 'correct-token-1234567890123456',
        now: now,
      );
      expect(result.status, PermissionValidationStatus.valid);
    });

    test('returns expired after validUntil', () {
      final result = PermissionValidator.evaluate(
        permission: _permission(
          validFrom: now.subtract(const Duration(hours: 2)),
          validUntil: now.subtract(const Duration(minutes: 1)),
        ),
        receivedToken: 'correct-token-1234567890123456',
        now: now,
      );
      expect(result.status, PermissionValidationStatus.expired);
    });

    test('returns unauthorized when the token differs', () {
      final result = PermissionValidator.evaluate(
        permission: _permission(
          validFrom: now.subtract(const Duration(hours: 1)),
          validUntil: now.add(const Duration(hours: 1)),
        ),
        receivedToken: 'incorrect-token',
        now: now,
      );
      expect(result.status, PermissionValidationStatus.unauthorized);
    });

    test('returns invalid for a cancelled permission', () {
      final result = PermissionValidator.evaluate(
        permission: _permission(
          validFrom: now.subtract(const Duration(hours: 1)),
          validUntil: now.add(const Duration(hours: 1)),
          status: 'cancelled',
        ),
        receivedToken: 'correct-token-1234567890123456',
        now: now,
      );
      expect(result.status, PermissionValidationStatus.invalid);
    });
  });
}

PermissionRecord _permission({
  required DateTime validFrom,
  required DateTime validUntil,
  String status = 'active',
}) {
  return PermissionRecord(
    id: 'permission-01',
    studentId: 'student-01',
    studentName: 'Estudiante Demo',
    classId: 'class-10A',
    createdBy: 'technical-01',
    reason: 'Actividad escolar',
    destination: 'Laboratorio',
    validFrom: validFrom,
    validUntil: validUntil,
    status: status,
    qrToken: 'correct-token-1234567890123456',
    createdAt: validFrom,
  );
}
