import 'package:flutter/material.dart';

class SessionTile extends StatelessWidget {
  final String subject;
  final String difficulty;
  final int score;
  final int total;
  final bool timed;
  final String subtitle;
  final VoidCallback onTap;

  const SessionTile({
    super.key,
    required this.subject,
    required this.difficulty,
    required this.score,
    required this.total,
    required this.timed,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((score / total) * 100).round();
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$difficulty • ${timed ? 'Timed' : 'Untimed'} • $subtitle'),
        trailing: Chip(label: Text('$score/$total ($percent%)')),
      ),
    );
  }
}
