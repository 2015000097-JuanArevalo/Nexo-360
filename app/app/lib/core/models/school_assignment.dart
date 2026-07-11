import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolAssignment {
  final String id;
  final String title;
  final String description;
  final String course;
  final DateTime dueDate;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final String? attachmentUrl;

  const SchoolAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.course,
    required this.dueDate,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    required this.attachmentUrl,
  });

  factory SchoolAssignment.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SchoolAssignment.fromMap(
      document.id,
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory SchoolAssignment.fromMap(String id, Map<String, dynamic> data) {
    final attachment = data['attachmentUrl'] as String?;

    return SchoolAssignment(
      id: id,
      title: data['title'] as String? ?? 'Actividad sin título',
      description: data['description'] as String? ?? '',
      course: data['course'] as String? ?? 'General',
      dueDate: _dateFrom(data['dueDate']),
      teacherId: data['teacherId'] as String? ?? '',
      teacherName: data['teacherName'] as String? ?? 'Docente',
      createdAt: _dateFrom(data['createdAt']),
      attachmentUrl: attachment == null || attachment.trim().isEmpty
          ? null
          : attachment.trim(),
    );
  }

  bool get hasAttachment => attachmentUrl != null;

  static DateTime _dateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
