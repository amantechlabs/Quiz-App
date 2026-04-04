import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';

class SessionDetailScreen extends StatelessWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: FutureBuilder<List<DbSessionAnswer>>(
        future: db.sessionDao.answersForSession(sessionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final answers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: answers.length,
            itemBuilder: (_, i) {
              final a = answers[i];
              return Card(
                child: ListTile(
                  title: Text('Question ${i + 1}'),
                  subtitle: Text('Selected ${a.selectedIndex} • Correct ${a.isCorrect} • ${a.timeTakenSecs}s'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
