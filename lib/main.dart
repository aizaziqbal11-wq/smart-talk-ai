import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const SmartTalkAI());
}

class SmartTalkAI extends StatelessWidget {
  const SmartTalkAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Talk AI',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ChatScreen(),
    );
  }
}
