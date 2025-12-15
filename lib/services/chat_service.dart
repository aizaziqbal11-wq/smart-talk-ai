import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _chatsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('chats');

  CollectionReference<Map<String, dynamic>> _messagesRef(
    String uid,
    String chatId,
  ) => _chatsRef(uid).doc(chatId).collection('messages');

  Future<String> createChat({String? title}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    final doc = _chatsRef(uid).doc();
    await doc.set({
      'title': title ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateChatTitle({
    required String chatId,
    required String title,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _chatsRef(
      uid,
    ).doc(chatId).set({'title': title}, SetOptions(merge: true));
  }

  Future<void> addMessage({
    required String chatId,
    required String text,
    required bool isUser,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    await _messagesRef(uid, chatId).add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _chatsRef(uid).orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String chatId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _messagesRef(uid, chatId).orderBy('timestamp').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLastMessage(String chatId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _messagesRef(
      uid,
      chatId,
    ).orderBy('timestamp', descending: true).limit(1).snapshots();
  }
}
