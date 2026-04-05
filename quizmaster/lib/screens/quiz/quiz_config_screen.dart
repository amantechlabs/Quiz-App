import 'package:flutter/material.dart';

import 'quiz_screen.dart';

class QuizConfigScreen extends StatefulWidget {
  final String subject;
  const QuizConfigScreen({super.key, required this.subject});

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String difficulty = 'easy';
  int count = 5;
  bool timed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'easy', label: Text('Easy')),
              ButtonSegment(value: 'medium', label: Text('Medium')),
              ButtonSegment(value: 'hard', label: Text('Hard')),
            ],
            selected: {difficulty},
            onSelectionChanged: (s) => setState(() => difficulty = s.first),
          ),
          const SizedBox(height: 20),
          const Text('Question count', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [5, 10, 15].map((v) {
              final selected = count == v;
              return ChoiceChip(
                label: Text('$v'),
                selected: selected,
                onSelected: (_) => setState(() => count = v),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Timed quiz'),
            subtitle: const Text('15 seconds per question'),
            value: timed,
            onChanged: (v) => setState(() => timed = v),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    subject: widget.subject,
                    difficulty: difficulty,
                    count: count,
                    timed: timed,
                  ),
                ),
              );
            },
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }
}
