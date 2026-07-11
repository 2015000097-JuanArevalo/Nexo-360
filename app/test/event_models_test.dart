import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/models/event_record.dart';
import 'package:nexo_360/core/models/event_registration.dart';

void main() {
  test('EventRecord reads the Milestone 5 event fields', () {
    final date = DateTime(2026, 7, 18, 8);
    final event = EventRecord.fromMap('event-01', {
      'name': 'Encuentro Juvenil NEXO 2026',
      'date': Timestamp.fromDate(date),
      'location': 'Colegio Don Bosco',
      'description': 'Jornada juvenil.',
      'capacity': 120,
      'isPublic': true,
      'registrationOpen': true,
      'status': 'active',
    });

    expect(event.id, 'event-01');
    expect(event.date, date);
    expect(event.capacity, 120);
    expect(event.registrationOpen, isTrue);
  });

  test('EventRegistration reads approval and check-in state', () {
    final checkIn = DateTime(2026, 7, 18, 8, 5);
    final registration = EventRegistration.fromMap('registration-01', {
      'eventId': 'event-01',
      'fullName': 'Participante Demo',
      'email': 'demo@example.com',
      'phone': '55555555',
      'organization': 'Colegio Don Bosco',
      'status': 'approved',
      'documentUrl': null,
      'createdAt': Timestamp.fromDate(DateTime(2026, 7, 11)),
      'checkedIn': true,
      'checkedInAt': Timestamp.fromDate(checkIn),
      'checkedInBy': 'organizer-01',
    });

    expect(registration.status, 'approved');
    expect(registration.checkedIn, isTrue);
    expect(registration.checkedInAt, checkIn);
  });
}
