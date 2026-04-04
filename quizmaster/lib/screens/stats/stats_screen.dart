import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ProfileProvider>().activeProfile;
    if (active == null) return const Center(child: Text('No profile selected.'));

    return FutureBuilder(
      future: context.read<HistoryProvider>().sessionsForProfile(active.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sessions = snapshot.data as List;
        final totalSessions = sessions.length;
        final totalQuestions = sessions.fold<int>(0, (sum, s) => sum + s.total);
        final totalCorrect = sessions.fold<int>(0, (sum, s) => sum + s.score);
        final avgScore = totalQuestions == 0 ? 0.0 : (totalCorrect / totalQuestions) * 100;
        final best = sessions.isEmpty ? 0 : sessions.map((s) => s.score).reduce((a, b) => a > b ? a : b);

        final bySubject = <String, double>{};
        for (final s in sessions) {
          bySubject[s.subject] = (bySubject[s.subject] ?? 0) + (s.total == 0 ? 0 : s.score / s.total);
        }
        final bars = bySubject.entries.take(6).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                StatCard(title: 'Quizzes', value: '$totalSessions', icon: Icons.quiz_outlined),
                StatCard(title: 'Questions', value: '$totalQuestions', icon: Icons.help_outline),
                StatCard(title: 'Average', value: '${avgScore.toStringAsFixed(1)}%', icon: Icons.percent),
                StatCard(title: 'Best', value: '$best', icon: Icons.emoji_events_outlined),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Subject accuracy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (var i = 0; i < bars.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: (bars[i].value * 100).clamp(0, 100)),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= bars.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(bars[index].key.substring(0, 3)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
