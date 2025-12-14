import 'package:flutter/material.dart';
import '../widgets/history_tile.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text("Chat History (Last 7 Days)")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return HistoryTile(text: history[index]);
        },
      ),
    );
  }
}
