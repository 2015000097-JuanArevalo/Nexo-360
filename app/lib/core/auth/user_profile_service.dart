import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.data()!);
  }
}
