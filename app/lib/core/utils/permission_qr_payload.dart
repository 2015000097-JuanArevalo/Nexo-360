import 'dart:convert';

class PermissionQrPayload {
  final String permissionId;
  final String qrToken;

  const PermissionQrPayload({
    required this.permissionId,
    required this.qrToken,
  });

  String encode() {
    return jsonEncode({
      'type': 'nexo360_permission',
      'permissionId': permissionId,
      'qrToken': qrToken,
    });
  }

  String encodeManual() => '$permissionId|$qrToken';

  static PermissionQrPayload? tryParse(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic> &&
          decoded['type'] == 'nexo360_permission') {
        final permissionId = decoded['permissionId'];
        final qrToken = decoded['qrToken'];
        if (permissionId is String &&
            permissionId.isNotEmpty &&
            qrToken is String &&
            qrToken.isNotEmpty) {
          return PermissionQrPayload(
            permissionId: permissionId,
            qrToken: qrToken,
          );
        }
      }
    } catch (_) {
      // The manual representation is attempted below.
    }

    final parts = value.split('|');
    if (parts.length != 2 || parts.any((part) => part.trim().isEmpty)) {
      return null;
    }
    return PermissionQrPayload(
      permissionId: parts[0].trim(),
      qrToken: parts[1].trim(),
    );
  }
}
