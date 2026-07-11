import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/event_record.dart';
import '../models/event_registration.dart';

class EventService {
  static const sampleEventId = 'encuentro-juvenil-nexo-2026';

  final FirebaseFirestore _firestore;

  EventService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<EventRecord>> watchPublicEvents() {
    return _firestore
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map(EventRecord.fromDocument).toList();
          events.sort((a, b) => a.date.compareTo(b.date));
          return events;
        });
  }

  Future<EventRecord?> loadRegistrationEvent(String? eventId) async {
    if (eventId != null && eventId.isNotEmpty) {
      final document = await _firestore.collection('events').doc(eventId).get();
      if (document.exists && document.data() != null) {
        return EventRecord.fromDocument(document);
      }
    }

    final snapshot = await _firestore
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .get();
    final events = snapshot.docs
        .map(EventRecord.fromDocument)
        .where((event) => event.registrationOpen && event.status == 'active')
        .toList();
    events.sort((a, b) => a.date.compareTo(b.date));
    return events.isEmpty ? null : events.first;
  }

  Future<void> createSampleEvent(AppUser user) async {
    if (!user.canManageEventRegistrations) {
      throw StateError('El usuario no administra eventos.');
    }
    final reference = _firestore.collection('events').doc(sampleEventId);
    final existing = await reference.get();
    if (existing.exists) return;
    await reference.set({
      'name': 'Encuentro Juvenil NEXO 2026',
      'date': Timestamp.fromDate(DateTime(2026, 7, 18, 8)),
      'location': 'Colegio Don Bosco',
      'description':
          'Jornada de formación, convivencia y participación juvenil de NEXO 360.',
      'capacity': 120,
      'isPublic': true,
      'registrationOpen': true,
      'status': 'active',
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> submitRegistration({
    required String eventId,
    required String fullName,
    required String email,
    required String phone,
    required String organization,
    String? documentUrl,
  }) async {
    final reference = _firestore.collection('event_registrations').doc();
    await reference.set({
      'eventId': eventId,
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'organization': organization.trim(),
      'status': 'pending',
      'documentUrl': (documentUrl?.trim().isEmpty ?? true)
          ? null
          : documentUrl!.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'checkedIn': false,
      'checkedInAt': null,
      'checkedInBy': null,
    });
    return reference.id;
  }

  Stream<EventRegistration?> watchRegistration(String registrationId) {
    return _firestore
        .collection('event_registrations')
        .doc(registrationId)
        .snapshots()
        .map(
          (document) => document.exists && document.data() != null
              ? EventRegistration.fromDocument(document)
              : null,
        );
  }

  Stream<List<EventRegistration>> watchRegistrations() {
    return _firestore.collection('event_registrations').snapshots().map((
      snapshot,
    ) {
      final registrations = snapshot.docs
          .map(EventRegistration.fromDocument)
          .toList();
      registrations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return registrations;
    });
  }

  Future<void> updateRegistrationStatus({
    required String registrationId,
    required String status,
  }) async {
    if (!const ['approved', 'reserved', 'rejected'].contains(status)) {
      throw ArgumentError('Estado de inscripción inválido.');
    }
    await _firestore
        .collection('event_registrations')
        .doc(registrationId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> checkIn({
    required EventRegistration registration,
    required AppUser user,
  }) async {
    if (!user.canManageEventRegistrations ||
        registration.status != 'approved') {
      throw StateError('Solo una inscripción aprobada puede registrarse.');
    }
    await _firestore
        .collection('event_registrations')
        .doc(registration.id)
        .update({
          'checkedIn': true,
          'checkedInAt': FieldValue.serverTimestamp(),
          'checkedInBy': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
