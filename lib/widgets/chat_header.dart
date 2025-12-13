import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      width: double.infinity,
      color: Colors.indigo,
      child: const Column(
        children: [
          Text(
            "Smart Talk AI",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            "Communication Assistant",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
