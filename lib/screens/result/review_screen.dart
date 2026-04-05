import 'package:flutter/material.dart';
import '../../models/session_answer.dart';

class ReviewScreen extends StatelessWidget {
  final List<SessionAnswer> answers;
  
  const ReviewScreen({required this.answers, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView.builder(
        itemCount: answers.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text('Question ${i + 1}'),
          subtitle: Text('Your answer: ${answers[i].selectedIndex}'),
        ),
      ),
    );
  }
}
