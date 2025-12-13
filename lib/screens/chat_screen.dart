import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [
    Message(text: "Hi 👋 I am Smart Talk AI. How can I help you?", isUser: false),
  ];

  void sendMessage(String text) {
    setState(() {
      messages.add(Message(text: text, isUser: true));
      messages.add(
        Message(text: "This is a demo response for now.", isUser: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ChatHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
          ChatInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
