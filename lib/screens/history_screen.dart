import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import 'chat_screen_from_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const List<String> history = [
    "How to improve communication?",
    "Explain 7Cs of communication",
    "Public speaking tips",
    "Conflict resolution advice",
  ];

  @override
  Widget build(BuildContext context) {
    final service = ChatService();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat History')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = (data['title'] as String?)?.isNotEmpty == true
                  ? data['title'] as String
                  : 'Untitled';
              final created = (data['createdAt'] as Timestamp?)?.toDate();
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: service.streamLastMessage(doc.id),
                builder: (context, lastSnap) {
                  final lastDocs = lastSnap.data?.docs;
                  final lastText = (lastDocs != null && lastDocs.isNotEmpty)
                      ? (lastDocs.first.data()['text'] as String? ?? '')
                      : null;
                  return ListTile(
                    title: Text(title),
                    subtitle: lastText != null
                        ? Text(
                            lastText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : (created != null
                              ? Text('${created.toLocal()}')
                              : null),
                    leading: const CircleAvatar(
                      child: Icon(Icons.chat_bubble_outline),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreenFromHistory(chatId: doc.id, title: title),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
