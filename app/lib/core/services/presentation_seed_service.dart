import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../utils/permission_qr_payload.dart';

class PresentationSeedResult {
  final String studentName;
  final String validPermissionCode;
  final String expiredPermissionCode;

  const PresentationSeedResult({
    required this.studentName,
    required this.validPermissionCode,
    required this.expiredPermissionCode,
  });
}

class PresentationSeedService {
  static const validPermissionId = 'presentation-permission-valid';
  static const expiredPermissionId = 'presentation-permission-expired';
  static const validToken = 'nexo360-demo-valid-token-2026';
  static const expiredToken = 'nexo360-demo-expired-token-2026';

  final FirebaseFirestore _firestore;

  PresentationSeedService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<PresentationSeedResult> seed(AppUser technicalUser) async {
    if (!technicalUser.isActive || !technicalUser.isTechnical) {
      throw StateError('Solo una cuenta técnica activa prepara la demo.');
    }

    final student = await _loadStudent();
    final now = DateTime.now();

    await _resetDocument('school_announcements', 'presentation-announcement', {
      'title': 'Presentación NEXO 360',
      'message':
          'Datos integrados listos para demostrar Portal Escolar, permisos y eventos.',
      'course': 'General',
      'authorId': technicalUser.uid,
      'authorName': technicalUser.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _resetDocument('school_activities', 'presentation-assignment', {
      'title': 'Actividad de demostración integrada',
      'description':
          'Abrir esta actividad para comprobar el flujo compartido entre roles.',
      'course': 'General',
      'dueDate': Timestamp.fromDate(now.add(const Duration(days: 3))),
      'teacherId': technicalUser.uid,
      'teacherName': technicalUser.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'attachmentUrl': 'https://example.com/nexo360-demo.pdf',
      'classId': student.classId,
      'status': 'published',
    });

    await _upsertPermission(
      id: validPermissionId,
      token: validToken,
      technicalUser: technicalUser,
      student: student,
      validFrom: now.subtract(const Duration(hours: 1)),
      validUntil: now.add(const Duration(hours: 8)),
      reason: 'Demostración de permiso válido',
    );
    await _upsertPermission(
      id: expiredPermissionId,
      token: expiredToken,
      technicalUser: technicalUser,
      student: student,
      validFrom: now.subtract(const Duration(hours: 5)),
      validUntil: now.subtract(const Duration(hours: 2)),
      reason: 'Demostración de permiso expirado',
    );

    await _upsertPresentationEvent(technicalUser, now);
    await _resetPendingRegistration();

    return PresentationSeedResult(
      studentName: student.displayName,
      validPermissionCode: const PermissionQrPayload(
        permissionId: validPermissionId,
        qrToken: validToken,
      ).encodeManual(),
      expiredPermissionCode: const PermissionQrPayload(
        permissionId: expiredPermissionId,
        qrToken: expiredToken,
      ).encodeManual(),
    );
  }

  Future<AppUser> _loadStudent() async {
    final snapshot = await _firestore
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .get();
    final students = snapshot.docs
        .map(
          (document) =>
              AppUser.fromMap({...document.data(), 'uid': document.id}),
        )
        .where((student) => student.isActive)
        .toList();
    if (students.isEmpty) {
      throw StateError('No existe un estudiante activo para la demo.');
    }
    students.sort((a, b) => a.displayName.compareTo(b.displayName));
    return students.first;
  }

  Future<void> _resetDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final reference = _firestore.collection(collection).doc(documentId);
    final document = await reference.get();
    if (document.exists) await reference.delete();
    await reference.set(data);
  }

  Future<void> _upsertPermission({
    required String id,
    required String token,
    required AppUser technicalUser,
    required AppUser student,
    required DateTime validFrom,
    required DateTime validUntil,
    required String reason,
  }) async {
    final reference = _firestore.collection('permissions').doc(id);
    final document = await reference.get();
    if (document.exists) await reference.delete();
    await reference.set({
      'studentId': student.uid,
      'studentName': student.displayName,
      'classId': student.classId,
      'createdBy': technicalUser.uid,
      'reason': reason,
      'destination': 'Auditorio Don Bosco',
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'qrToken': token,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdFromRequestId': null,
    });
  }

  Future<void> _upsertPresentationEvent(
    AppUser technicalUser,
    DateTime now,
  ) async {
    final reference = _firestore.collection('events').doc('presentation-event');
    final document = await reference.get();
    if (document.exists) await reference.delete();
    await reference.set({
      'name': 'Encuentro de presentación NEXO 360',
      'date': Timestamp.fromDate(now.add(const Duration(days: 7))),
      'location': 'Colegio Don Bosco',
      'description':
          'Evento preparado para demostrar inscripción, aprobación y check-in.',
      'capacity': 120,
      'isPublic': true,
      'registrationOpen': true,
      'status': 'active',
      'createdBy': technicalUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _resetPendingRegistration() async {
    final reference = _firestore
        .collection('event_registrations')
        .doc('presentation-registration-pending');
    final existing = await reference.get();
    if (existing.exists) await reference.delete();
    await reference.set({
      'eventId': 'presentation-event',
      'fullName': 'Participante Presentación',
      'email': 'participant.demo@nexo360.test',
      'phone': '55551234',
      'organization': 'Colegio Don Bosco',
      'status': 'pending',
      'documentUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'checkedIn': false,
      'checkedInAt': null,
      'checkedInBy': null,
    });
  }
}
