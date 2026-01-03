import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> createUserIfNotExists({
    required String uid,
    required String email,
  }) async {
    final doc = _users.doc(uid);
    final snapshot = await doc.get();

    if (snapshot.exists) return;

    await doc.set({
      'userId': uid,
      'email': email,
      'username': null,
      'profilePhotoUrl': null,
      'blockedUserIds': [],
      'birthDate': null,
      'gender': null,
      'preferences': {},
      'settings': {},
      'hasOnboarded': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
