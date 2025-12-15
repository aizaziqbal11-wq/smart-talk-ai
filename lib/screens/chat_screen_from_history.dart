import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenFromHistory extends StatefulWidget {
  final String chatId;
  final String title;

  const ChatScreenFromHistory({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  State<ChatScreenFromHistory> createState() => _ChatScreenFromHistoryState();
}

class _ChatScreenFromHistoryState extends State<ChatScreenFromHistory> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _service = ChatService();
  String _selectedRole = 'Friend';
  final Map<String, IconData> _roleIcons = {
    'Friend': Icons.people,
    'Boss/Manager': Icons.business_center,
    'Family Member': Icons.family_restroom,
    'Teacher/Professor': Icons.school,
    'Default': Icons.person,
  };

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _service.addMessage(chatId: widget.chatId, text: text, isUser: true);
    _controller.clear();

    // dummy AI response
    await _service.addMessage(
      chatId: widget.chatId,
      text: 'This is AI response (demo)',
      isUser: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _service.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final msg = Message(
                      text: d['text'] as String? ?? '',
                      isUser: d['isUser'] as bool? ?? false,
                    );
                    return ChatBubble(message: msg);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton<String>(
                    tooltip: 'Select role',
                    onSelected: (value) =>
                        setState(() => _selectedRole = value),
                    itemBuilder: (context) => _roleIcons.keys
                        .where((k) => k != 'Default')
                        .map(
                          (role) => PopupMenuItem(
                            value: role,
                            child: Row(
                              children: [
                                Icon(_roleIcons[role], color: Colors.indigo),
                                const SizedBox(width: 8),
                                Text(role),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade500,
                            Colors.indigo.shade300,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withAlpha(51),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _roleIcons[_selectedRole] ?? _roleIcons['Default'],
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedRole,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                        child: Icon(
                          _roleIcons[_selectedRole] ?? _roleIcons['Default'],
                          color: Colors.indigo,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
