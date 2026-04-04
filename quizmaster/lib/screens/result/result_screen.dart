import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../providers/history_provider.dart';
import '../history/history_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int sessionId;
  final String subject;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.sessionId,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (score / total) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$score / $total', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('${percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              Text(
                percent >= 90 ? 'Outstanding' : percent >= 70 ? 'Great' : percent >= 50 ? 'Not Bad' : 'Keep Practicing',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                },
                child: const Text('View History'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
