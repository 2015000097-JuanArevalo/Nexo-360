import 'package:cloud_firestore/cloud_firestore.dart';

class EventRegistration {
  final String id;
  final String eventId;
  final String fullName;
  final String email;
  final String phone;
  final String organization;
  final String status;
  final String? documentUrl;
  final DateTime createdAt;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final String? checkedInBy;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.organization,
    required this.status,
    required this.documentUrl,
    required this.createdAt,
    required this.checkedIn,
    required this.checkedInAt,
    required this.checkedInBy,
  });

  factory EventRegistration.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return EventRegistration.fromMap(
      document.id,
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory EventRegistration.fromMap(String id, Map<String, dynamic> data) {
    return EventRegistration(
      id: id,
      eventId: data['eventId'] as String? ?? '',
      fullName: data['fullName'] as String? ?? 'Participante',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      organization: data['organization'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      documentUrl: data['documentUrl'] as String?,
      createdAt: _dateFrom(data['createdAt']),
      checkedIn: data['checkedIn'] as bool? ?? false,
      checkedInAt: _nullableDateFrom(data['checkedInAt']),
      checkedInBy: data['checkedInBy'] as String?,
    );
  }

  static DateTime _dateFrom(Object? value) {
    return _nullableDateFrom(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _nullableDateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
