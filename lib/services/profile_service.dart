import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(String uid) {
    return _users.doc(uid).get();
  }

  Future<void> createOrUpdateProfile({
    required String uid,
    required String name,
    String? photoUrl,
  }) async {
    await _users.doc(uid).set({
      'name': name,
      'photoUrl': photoUrl ?? FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child(
      'profiles/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final upload = await ref.putFile(file);
    final url = await upload.ref.getDownloadURL();
    return url;
  }
}
