import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/school_announcement.dart';
import '../models/school_assignment.dart';

class SchoolPortalService {
  final FirebaseFirestore _firestore;

  SchoolPortalService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SchoolAnnouncement>> watchAnnouncements() {
    return _firestore
        .collection('school_announcements')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SchoolAnnouncement.fromDocument)
              .toList(growable: false),
        );
  }

  Stream<List<SchoolAssignment>> watchAssignments() {
    return _firestore
        .collection('school_activities')
        .orderBy('dueDate')
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SchoolAssignment.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> createAssignment({
    required AppUser teacher,
    required String title,
    required String description,
    required String course,
    required DateTime dueDate,
    String? attachmentUrl,
  }) async {
    if (!teacher.canPublishSchoolContent) {
      throw StateError('El usuario no puede publicar actividades escolares.');
    }

    final cleanAttachment = attachmentUrl?.trim();
    await _firestore.collection('school_activities').add({
      'title': title.trim(),
      'description': description.trim(),
      'course': course,
      'dueDate': Timestamp.fromDate(dueDate),
      'teacherId': teacher.uid,
      'teacherName': teacher.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'attachmentUrl': cleanAttachment == null || cleanAttachment.isEmpty
          ? null
          : cleanAttachment,
      'classId': teacher.classId,
      'status': 'published',
    });
  }

  Future<void> seedSampleAnnouncements(AppUser author) async {
    if (!author.canPublishSchoolContent) {
      throw StateError('El usuario no puede publicar avisos escolares.');
    }

    final batch = _firestore.batch();
    final announcements = <String, Map<String, dynamic>>{
      'announcement-demo-01': {
        'title': 'Jornada deportiva Don Bosco',
        'message': 'Asistir el viernes con uniforme deportivo y agua pura.',
        'course': 'General',
      },
      'announcement-demo-02': {
        'title': 'Reunión de padres de familia',
        'message': 'La reunión se realizará el jueves a las 4:00 p. m.',
        'course': '10A',
      },
      'announcement-demo-03': {
        'title': 'Movimiento Juventud',
        'message':
            'Las inscripciones para el encuentro juvenil están abiertas.',
        'course': 'General',
      },
    };

    for (final entry in announcements.entries) {
      final reference = _firestore
          .collection('school_announcements')
          .doc(entry.key);
      batch.set(reference, {
        ...entry.value,
        'authorId': author.uid,
        'authorName': author.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
