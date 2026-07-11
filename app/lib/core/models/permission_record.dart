import 'package:cloud_firestore/cloud_firestore.dart';

class PermissionRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String? classId;
  final String createdBy;
  final String reason;
  final String destination;
  final DateTime validFrom;
  final DateTime validUntil;
  final String status;
  final String qrToken;
  final DateTime createdAt;

  const PermissionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.createdBy,
    required this.reason,
    required this.destination,
    required this.validFrom,
    required this.validUntil,
    required this.status,
    required this.qrToken,
    required this.createdAt,
  });

  factory PermissionRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return PermissionRecord.fromMap(
      document.id,
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory PermissionRecord.fromMap(String id, Map<String, dynamic> data) {
    return PermissionRecord(
      id: id,
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? 'Estudiante',
      classId: data['classId'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      validFrom: _dateFrom(data['validFrom']),
      validUntil: _dateFrom(data['validUntil']),
      status: data['status'] as String? ?? 'cancelled',
      qrToken: data['qrToken'] as String? ?? '',
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  bool isCurrentlyValid(DateTime now) {
    return status == 'active' &&
        !now.isBefore(validFrom) &&
        now.isBefore(validUntil);
  }

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

enum PermissionValidationStatus {
  valid,
  expired,
  unauthorized,
  notFound,
  invalid,
  notYetValid,
}

class PermissionValidationResult {
  final PermissionValidationStatus status;
  final String message;
  final PermissionRecord? permission;

  const PermissionValidationResult({
    required this.status,
    required this.message,
    this.permission,
  });
}
