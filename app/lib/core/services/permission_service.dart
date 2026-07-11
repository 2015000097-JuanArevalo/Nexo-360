import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/permission_record.dart';
import '../models/permission_request.dart';
import '../utils/permission_qr_payload.dart';
import 'permission_validator.dart';

class PermissionService {
  final FirebaseFirestore _firestore;

  PermissionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AppUser>> loadActiveStudents() async {
    final snapshot = await _firestore
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .get();

    final students = snapshot.docs
        .map(
          (document) =>
              AppUser.fromMap({...document.data(), 'uid': document.id}),
        )
        .where((user) => user.isActive)
        .toList();
    students.sort((a, b) => a.displayName.compareTo(b.displayName));
    return students;
  }

  Stream<List<PermissionRecord>> watchStudentPermissions(String studentId) {
    return _firestore
        .collection('permissions')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final permissions = snapshot.docs
              .map(PermissionRecord.fromDocument)
              .toList();
          permissions.sort((a, b) => b.validUntil.compareTo(a.validUntil));
          return permissions;
        });
  }

  Stream<List<PermissionRequest>> watchPendingPermissionRequests() {
    return _firestore
        .collection('permission_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map(PermissionRequest.fromDocument)
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<PermissionQrPayload> createPermission({
    required AppUser creator,
    required AppUser student,
    required String reason,
    required String destination,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    if (!creator.isTechnical) {
      throw StateError('Solo el personal técnico crea permisos reales.');
    }
    if (!student.isStudent) {
      throw ArgumentError('El permiso debe asignarse a un estudiante.');
    }
    if (!validUntil.isAfter(validFrom)) {
      throw ArgumentError('La fecha final debe ser posterior a la inicial.');
    }

    final reference = _firestore.collection('permissions').doc();
    final token = _generateSecureToken();
    await reference.set({
      'studentId': student.uid,
      'studentName': student.displayName,
      'classId': student.classId,
      'createdBy': creator.uid,
      'reason': reason.trim(),
      'destination': destination.trim(),
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'qrToken': token,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdFromRequestId': null,
    });

    return PermissionQrPayload(permissionId: reference.id, qrToken: token);
  }

  Future<void> createPermissionRequest({
    required AppUser requester,
    required AppUser student,
    required String reason,
    required String destination,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    if (!requester.canRequestPermission) {
      throw StateError('El usuario no puede solicitar permisos.');
    }
    if (!validUntil.isAfter(validFrom)) {
      throw ArgumentError('La fecha final debe ser posterior a la inicial.');
    }

    await _firestore.collection('permission_requests').add({
      'requestType': 'create',
      'targetPermissionId': null,
      'requestedBy': requester.uid,
      'requestDescription': reason.trim(),
      'status': 'pending',
      'proposedData': {
        'studentId': student.uid,
        'studentName': student.displayName,
        'classId': student.classId,
        'reason': reason.trim(),
        'destination': destination.trim(),
        'validFrom': Timestamp.fromDate(validFrom),
        'validUntil': Timestamp.fromDate(validUntil),
      },
      'reviewedBy': null,
      'reviewComment': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> approvePermissionRequest({
    required PermissionRequest request,
    required AppUser reviewer,
  }) async {
    if (!reviewer.isTechnical) {
      throw StateError('Solo el personal técnico aprueba solicitudes.');
    }
    if (request.status != 'pending') {
      throw StateError('La solicitud ya fue procesada.');
    }

    final requestReference = _firestore
        .collection('permission_requests')
        .doc(request.id);
    final permissionReference = _firestore.collection('permissions').doc();
    final token = _generateSecureToken();
    final batch = _firestore.batch();

    batch.set(permissionReference, {
      'studentId': request.studentId,
      'studentName': request.studentName,
      'classId': request.classId,
      'createdBy': reviewer.uid,
      'reason': request.reason,
      'destination': request.destination,
      'validFrom': Timestamp.fromDate(request.validFrom),
      'validUntil': Timestamp.fromDate(request.validUntil),
      'status': 'active',
      'qrToken': token,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdFromRequestId': request.id,
    });
    batch.update(requestReference, {
      'status': 'approved',
      'targetPermissionId': permissionReference.id,
      'reviewedBy': reviewer.uid,
      'reviewComment': 'Aprobado por personal técnico.',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return permissionReference.id;
  }

  Future<void> denyPermissionRequest({
    required PermissionRequest request,
    required AppUser reviewer,
  }) async {
    if (!reviewer.isTechnical) {
      throw StateError('Solo el personal técnico deniega solicitudes.');
    }
    await _firestore.collection('permission_requests').doc(request.id).update({
      'status': 'denied',
      'targetPermissionId': null,
      'reviewedBy': reviewer.uid,
      'reviewComment': 'Denegado por personal técnico.',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<PermissionValidationResult> validate(String rawPayload) async {
    final payload = PermissionQrPayload.tryParse(rawPayload);
    if (payload == null) {
      return const PermissionValidationResult(
        status: PermissionValidationStatus.unauthorized,
        message: 'El código no tiene el formato de NEXO 360.',
      );
    }

    final document = await _firestore
        .collection('permissions')
        .doc(payload.permissionId)
        .get();
    if (!document.exists || document.data() == null) {
      return const PermissionValidationResult(
        status: PermissionValidationStatus.notFound,
        message: 'No existe un permiso con este identificador.',
      );
    }

    final permission = PermissionRecord.fromDocument(document);
    return PermissionValidator.evaluate(
      permission: permission,
      receivedToken: payload.qrToken,
      now: DateTime.now(),
    );
  }

  String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
