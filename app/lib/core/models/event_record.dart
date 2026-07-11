import 'package:cloud_firestore/cloud_firestore.dart';

class EventRecord {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final int capacity;
  final bool isPublic;
  final bool registrationOpen;
  final String status;

  const EventRecord({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.capacity,
    required this.isPublic,
    required this.registrationOpen,
    required this.status,
  });

  factory EventRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return EventRecord.fromMap(
      document.id,
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory EventRecord.fromMap(String id, Map<String, dynamic> data) {
    return EventRecord(
      id: id,
      name: data['name'] as String? ?? data['title'] as String? ?? 'Evento',
      date: _dateFrom(data['date']),
      location: data['location'] as String? ?? 'Ubicación por confirmar',
      description: data['description'] as String? ?? '',
      capacity: data['capacity'] as int? ?? 0,
      isPublic: data['isPublic'] as bool? ?? false,
      registrationOpen: data['registrationOpen'] as bool? ?? false,
      status: data['status'] as String? ?? 'inactive',
    );
  }

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
