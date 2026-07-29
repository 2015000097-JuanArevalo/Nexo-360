import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore db;
  FirestoreService({FirebaseFirestore? db}) : db = db ?? FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchCollection(
    String path, {
    String? orderBy,
    bool descending = false,
    int limit = 200,
  }) {
    Query<Map<String, dynamic>> query = db.collection(path);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    return query.limit(limit).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<DocumentReference<Map<String, dynamic>>> add(
    String path,
    Map<String, dynamic> data,
  ) => db.collection(path).add(data);

  Future<void> set(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = true,
  }) => db.collection(path).doc(id).set(data, SetOptions(merge: merge));

  Future<void> update(String path, String id, Map<String, dynamic> data) =>
      db.collection(path).doc(id).update(data);

  Future<void> delete(String path, String id) => db.collection(path).doc(id).delete();
}
