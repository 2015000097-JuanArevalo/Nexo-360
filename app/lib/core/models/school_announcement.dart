import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolAnnouncement {
  final String id;
  final String title;
  final String message;
  final String course;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  const SchoolAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.course,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory SchoolAnnouncement.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SchoolAnnouncement.fromMap(
      document.id,
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory SchoolAnnouncement.fromMap(String id, Map<String, dynamic> data) {
    return SchoolAnnouncement(
      id: id,
      title: data['title'] as String? ?? 'Aviso sin título',
      message: data['message'] as String? ?? '',
      course: data['course'] as String? ?? 'General',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'NEXO 360',
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
