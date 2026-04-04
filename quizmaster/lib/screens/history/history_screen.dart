import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/session_tile.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ProfileProvider>().activeProfile;
    if (active == null) {
      return const Center(child: Text('No profile selected.'));
    }

    return FutureBuilder<List<DbSession>>(
      future: context.read<HistoryProvider>().recentSessions(active.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sessions = snapshot.data ?? const <DbSession>[];
        if (sessions.isEmpty) return const Center(child: Text('No sessions yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (_, i) {
            final s = sessions[i];
            return SessionTile(
              subject: s.subject,
              difficulty: s.difficulty,
              score: s.score,
              total: s.total,
              timed: s.timed,
              subtitle: s.completedAt,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: s.id)));
              },
            );
          },
        );
      },
    );
  }
}
