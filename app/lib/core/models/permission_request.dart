import 'package:cloud_firestore/cloud_firestore.dart';

class PermissionRequest {
  final String id;
  final String requestedBy;
  final String requestDescription;
  final String status;
  final String? targetPermissionId;
  final String studentId;
  final String studentName;
  final String? classId;
  final String reason;
  final String destination;
  final DateTime validFrom;
  final DateTime validUntil;
  final DateTime createdAt;

  const PermissionRequest({
    required this.id,
    required this.requestedBy,
    required this.requestDescription,
    required this.status,
    required this.targetPermissionId,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.reason,
    required this.destination,
    required this.validFrom,
    required this.validUntil,
    required this.createdAt,
  });

  factory PermissionRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final proposedData =
        data['proposedData'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    return PermissionRequest(
      id: document.id,
      requestedBy: data['requestedBy'] as String? ?? '',
      requestDescription: data['requestDescription'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      targetPermissionId: data['targetPermissionId'] as String?,
      studentId: proposedData['studentId'] as String? ?? '',
      studentName: proposedData['studentName'] as String? ?? 'Estudiante',
      classId: proposedData['classId'] as String?,
      reason: proposedData['reason'] as String? ?? '',
      destination: proposedData['destination'] as String? ?? '',
      validFrom: _dateFrom(proposedData['validFrom']),
      validUntil: _dateFrom(proposedData['validUntil']),
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
