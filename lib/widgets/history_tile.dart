import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final String text;

  const HistoryTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chat_bubble_outline),
      title: Text(text),
      subtitle: Text("Tap to view conversation"),
    );
  }
}
