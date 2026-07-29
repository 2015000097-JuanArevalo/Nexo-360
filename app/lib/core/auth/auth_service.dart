import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authChanges => auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => auth.signOut();

  Future<AppUser?> loadProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> updateProfile(AppUser user) =>
      firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));

  Future<String> createManagedUser({
    required AppUser technical,
    required String email,
    required String password,
    required String displayName,
    required String accountType,
    required String eventRole,
    required String schoolCode,
    required String classId,
  }) async {
    if (!technical.isTechnical) {
      throw StateError('Solo una cuenta técnica puede crear usuarios.');
    }
    FirebaseApp secondary;
    try {
      secondary = Firebase.app('user-creation');
    } catch (_) {
      secondary = await Firebase.initializeApp(
        name: 'user-creation',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
    final credential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(displayName.trim());
    final batch = firestore.batch();
    batch.set(firestore.collection('users').doc(uid), {
      'email': email.trim().toLowerCase(),
      'displayName': displayName.trim(),
      'accountType': accountType,
      'eventRole': eventRole,
      'status': 'active',
      'schoolCode': schoolCode.trim(),
      'classId': classId.trim(),
      'courseIds': <String>[],
      'committeeId': '',
      'eventPermissions': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': technical.uid,
    });
    batch.set(firestore.collection('directory_profiles').doc(uid), {
      'displayName': displayName.trim(),
      'accountType': accountType,
      'eventRole': eventRole,
      'status': 'active',
      'classId': classId.trim(),
      'committeeId': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await secondaryAuth.signOut();
    return uid;
  }
}
