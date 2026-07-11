import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class DashboardSummaryService {
  final FirebaseFirestore _firestore;

  DashboardSummaryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<int> watchPendingAssignments() {
    return _firestore.collection('school_activities').snapshots().map((
      snapshot,
    ) {
      final now = DateTime.now();
      return snapshot.docs.where((document) {
        final data = document.data();
        final dueDate = data['dueDate'];
        return data['status'] == 'published' &&
            dueDate is Timestamp &&
            dueDate.toDate().isAfter(now);
      }).length;
    });
  }

  Stream<int?> watchActivePermissions(AppUser user) {
    Query<Map<String, dynamic>>? query;
    if (user.isTechnical) {
      query = _firestore.collection('permissions');
    } else if (user.isStudent) {
      query = _firestore
          .collection('permissions')
          .where('studentId', isEqualTo: user.uid);
    } else if (user.isTeacher || user.isEventOrganizer) {
      return _firestore
          .collection('permission_requests')
          .where('requestedBy', isEqualTo: user.uid)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .where((document) => document.data()['status'] == 'pending')
                .length,
          );
    }
    if (query == null) return Stream<int?>.value(null);

    return query.snapshots().map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.where((document) {
        final data = document.data();
        final validFrom = data['validFrom'];
        final validUntil = data['validUntil'];
        return data['status'] == 'active' &&
            validFrom is Timestamp &&
            validUntil is Timestamp &&
            !now.isBefore(validFrom.toDate()) &&
            now.isBefore(validUntil.toDate());
      }).length;
    });
  }

  Stream<int?> watchPendingRegistrations(AppUser user) {
    if (!user.canManageEventRegistrations) {
      return Stream<int?>.value(null);
    }
    return _firestore
        .collection('event_registrations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((document) => document.data()['status'] == 'pending')
              .length,
        );
  }

  Stream<String?> watchLatestAnnouncement() {
    return _firestore.collection('school_announcements').snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) return null;
      final documents = snapshot.docs.toList()
        ..sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];
          final aMilliseconds = aDate is Timestamp
              ? aDate.millisecondsSinceEpoch
              : 0;
          final bMilliseconds = bDate is Timestamp
              ? bDate.millisecondsSinceEpoch
              : 0;
          return bMilliseconds.compareTo(aMilliseconds);
        });
      return documents.first.data()['title'] as String?;
    });
  }
}
