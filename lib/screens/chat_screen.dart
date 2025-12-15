import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chat_bubble.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import 'chat_screen_from_history.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _chatId;
  final ChatService _chatService = ChatService();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _messagesStream;
  String _selectedRole = 'Friend';
  final Map<String, IconData> _roleIcons = {
    'Friend': Icons.people,
    'Boss/Manager': Icons.business_center,
    'Family Member': Icons.family_restroom,
    'Teacher/Professor': Icons.school,
    'Default': Icons.person,
  };

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatId == null) return;

    _controller.clear();
    await _chatService.addMessage(chatId: _chatId!, text: text, isUser: true);

    // If chat has no title yet, set it to the first part of this message
    final chatDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chats')
        .doc(_chatId)
        .get();
    final currentTitle = chatDoc.data()?['title'] as String? ?? '';
    if (currentTitle.isEmpty) {
      final candidate = text.split('\n').first;
      final title = candidate.length > 40
          ? '${candidate.substring(0, 40)}...'
          : candidate;
      await _chatService.updateChatTitle(chatId: _chatId!, title: title);
    }

    // Dummy AI response
    await _chatService.addMessage(
      chatId: _chatId!,
      text: 'This is AI response (demo)',
      isUser: false,
    );
  }

  void newChat() {
    _createChat();
    setState(() => _selectedRole = 'Friend');
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started a new chat'),
        backgroundColor: Colors.indigo,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _createChat();
  }

  Future<void> _createChat() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to start a chat')),
      );
      return;
    }

    final id = await _chatService.createChat();
    setState(() {
      _chatId = id;
      _messagesStream = _chatService.streamMessages(id);
    });
  }

  Future<void> _openChatsList() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.streamChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty)
                  return const Center(child: Text('No chats yet'));
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final title = (data['title'] as String?)?.isNotEmpty == true
                        ? data['title'] as String
                        : 'Untitled';
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _chatService.streamLastMessage(doc.id),
                      builder: (context, lastSnap) {
                        final lastDocs = lastSnap.data?.docs;
                        final lastText =
                            (lastDocs != null && lastDocs.isNotEmpty)
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
                              : null,
                          leading: const CircleAvatar(
                            child: Icon(Icons.chat_bubble_outline),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreenFromHistory(
                                  chatId: doc.id,
                                  title: title,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade400],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: newChat,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'New chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(31),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Smart Talk AI",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Chats',
            onPressed: _openChatsList,
            icon: const Icon(Icons.menu),
          ),
        ],
        backgroundColor: Colors.indigo,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFDDE7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            /// CHAT AREA
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1000) {
                    // two column layout: left sidebar (roles/history) + chat area
                    return Row(
                      children: [
                        Container(
                          width: 320,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                'Chats',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child:
                                    StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>
                                    >(
                                      stream: _chatService.streamChats(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        final docs = snapshot.data?.docs ?? [];
                                        return ListView.builder(
                                          itemCount: docs.length,
                                          itemBuilder: (context, index) {
                                            final d = docs[index];
                                            final title =
                                                (d.data()['title'] as String?)
                                                        ?.isNotEmpty ==
                                                    true
                                                ? d.data()['title'] as String
                                                : 'Untitled';
                                            return ListTile(
                                              leading: const CircleAvatar(
                                                child: Icon(
                                                  Icons.chat_bubble_outline,
                                                ),
                                              ),
                                              title: Text(title),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ChatScreenFromHistory(
                                                        chatId: d.id,
                                                        title: title,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: _chatId == null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Start a conversation 👋",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Your intelligent communication assistant",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.4,
                                          foreground: Paint()
                                            ..shader =
                                                LinearGradient(
                                                  colors: [
                                                    Color(0xFF5B5CF7),
                                                    Color(0xFF00C6FF),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ).createShader(
                                                  Rect.fromLTWH(0, 0, 200, 24),
                                                ),
                                          shadows: [
                                            Shadow(
                                              color: Colors.indigo.withAlpha(
                                                51,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: _messagesStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final docs = snapshot.data?.docs ?? [];
                                    if (docs.isEmpty) {
                                      return const Center(
                                        child: Text('No messages yet'),
                                      );
                                    }
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
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
                      ],
                    );
                  }

                  // Mobile/tablet single column layout
                  return _chatId == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Start a conversation 👋",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Your intelligent communication assistant",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.4,
                                  foreground: Paint()
                                    ..shader =
                                        LinearGradient(
                                          colors: [
                                            Color(0xFF5B5CF7),
                                            Color(0xFF00C6FF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(
                                          Rect.fromLTWH(0, 0, 200, 24),
                                        ),
                                  shadows: [
                                    Shadow(
                                      color: Colors.indigo.withAlpha(51),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _messagesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return const Center(
                                child: Text('No messages yet'),
                              );
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
                        );
                },
              ),
            ),

            /// INPUT AREA
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
                  /// ROLE DROPDOWN
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
                              _roleIcons[_selectedRole] ??
                                  _roleIcons['Default'],
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

                  /// TEXT FIELD
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
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

                  /// SEND BUTTON
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
