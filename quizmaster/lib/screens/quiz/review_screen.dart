import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../providers/history_provider.dart';

class ReviewScreen extends StatelessWidget {
  final int sessionId;
  const ReviewScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Review Wrong Answers')),
      body: FutureBuilder<List<DbSessionAnswer>>(
        future: db.sessionDao.answersForSession(sessionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final wrong = snapshot.data!.where((a) => !a.isCorrect).toList();
          if (wrong.isEmpty) {
            return const Center(child: Text('No wrong answers in this session.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wrong.length,
            itemBuilder: (_, i) {
              final a = wrong[i];
              return Card(
                child: ListTile(
                  title: Text('Question #${a.questionId}'),
                  subtitle: Text('Selected: ${a.selectedIndex} • Time: ${a.timeTakenSecs}s'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
