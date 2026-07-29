class StudentQrPayload {
  final String uid;
  final String schoolCode;
  const StudentQrPayload(this.uid, this.schoolCode);

  String encode() => 'NEXO360|STUDENT|$uid|$schoolCode';

  static StudentQrPayload? tryParse(String raw) {
    final parts = raw.split('|');
    if (parts.length != 4 || parts[0] != 'NEXO360' || parts[1] != 'STUDENT') {
      return null;
    }
    return StudentQrPayload(parts[2], parts[3]);
  }
}

class PermissionQrPayload {
  final String permissionId;
  final String token;
  const PermissionQrPayload(this.permissionId, this.token);

  String encode() => 'NEXO360|PERMISSION|$permissionId|$token';

  static PermissionQrPayload? tryParse(String raw) {
    final parts = raw.split('|');
    if (parts.length != 4 || parts[0] != 'NEXO360' || parts[1] != 'PERMISSION') {
      return null;
    }
    return PermissionQrPayload(parts[2], parts[3]);
  }
}
