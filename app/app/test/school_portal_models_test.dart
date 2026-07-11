import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/models/school_announcement.dart';
import 'package:nexo_360/core/models/school_assignment.dart';
import 'package:nexo_360/core/utils/date_formatters.dart';

void main() {
  test('SchoolAssignment reads Firestore fields', () {
    final dueDate = DateTime(2026, 7, 12, 8, 0);
    final assignment = SchoolAssignment.fromMap('assignment-01', {
      'title': 'Investigación',
      'description': 'Preparar el documento.',
      'course': 'Ciencias',
      'dueDate': Timestamp.fromDate(dueDate),
      'teacherId': 'teacher-01',
      'teacherName': 'Docente Demo',
      'createdAt': Timestamp.fromDate(DateTime(2026, 7, 10)),
      'attachmentUrl': 'https://example.com/file.pdf',
    });

    expect(assignment.id, 'assignment-01');
    expect(assignment.course, 'Ciencias');
    expect(assignment.dueDate, dueDate);
    expect(assignment.hasAttachment, isTrue);
  });

  test('SchoolAnnouncement reads Firestore fields', () {
    final announcement = SchoolAnnouncement.fromMap('announcement-01', {
      'title': 'Jornada deportiva',
      'message': 'Asistir con uniforme deportivo.',
      'course': 'General',
      'authorId': 'teacher-01',
      'authorName': 'Docente Demo',
      'createdAt': Timestamp.fromDate(DateTime(2026, 7, 10)),
    });

    expect(announcement.title, 'Jornada deportiva');
    expect(announcement.authorName, 'Docente Demo');
  });

  test('school date formatter includes date and time', () {
    expect(
      formatSchoolDateTime(DateTime(2026, 7, 12, 13, 5)),
      '12/07/2026 · 1:05 p. m.',
    );
  });
}
