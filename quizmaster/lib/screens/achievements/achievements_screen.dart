import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/constants.dart';
import '../../utils/achievement_engine.dart';
import '../../widgets/achievement_badge.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ProfileProvider>().activeProfile;
    if (active == null) return const Center(child: Text('No profile selected.'));

    return FutureBuilder(
      future: Future.wait([
        context.read<HistoryProvider>().sessionsForProfile(active.id),
        context.read<HistoryProvider>().achievementsForProfile(active.id),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data as List;
        final sessions = data[0] as List<DbSession>;
        final unlocked = AchievementEngine.unlockedIds(
          sessions: sessions,
          existing: data[1] as List<DbAchievement>,
        );
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: AppConstants.achievementDefs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.92,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final item = AppConstants.achievementDefs[i];
            return AchievementBadge(
              title: item['title']!,
              hint: item['hint']!,
              unlocked: unlocked.contains(item['id']),
              icon: _iconFor(item['id']!),
            );
          },
        );
      },
    );
  }

  String _iconFor(String id) {
    switch (id) {
      case 'first_quiz': return '🎯';
      case 'perfect_score': return '💯';
      case 'streak_5': return '🔥';
      case 'all_subjects': return '📚';
      case 'hard_master': return '🧠';
      case 'speed_demon': return '🏃';
      case 'consistent_5': return '📅';
      case 'explorer': return '🌍';
      case 'hard_hero': return '⚡';
      default: return '🏅';
    }
  }
}
