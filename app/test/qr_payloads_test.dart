import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/utils/qr_payloads.dart';

void main() {
  test('student QR round trip', () {
    const source = StudentQrPayload('uid-123', '20260001');
    final parsed = StudentQrPayload.tryParse(source.encode());
    expect(parsed, isNotNull);
    expect(parsed!.uid, 'uid-123');
    expect(parsed.schoolCode, '20260001');
  });

  test('permission QR rejects malformed token', () {
    expect(PermissionQrPayload.tryParse('not-a-nexo-code'), isNull);
  });

  test('permission QR round trip', () {
    const source = PermissionQrPayload('permission-1', 'secure-token');
    final parsed = PermissionQrPayload.tryParse(source.encode());
    expect(parsed, isNotNull);
    expect(parsed!.permissionId, 'permission-1');
    expect(parsed.token, 'secure-token');
  });
}
