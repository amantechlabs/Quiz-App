import '../database/db_helper.dart';

class AchievementEngine {
  static Set<String> unlockedIds({
    required List<DbSession> sessions,
    required List<DbAchievement> existing,
  }) {
    final ids = existing.map((e) => e.achievement).toSet();

    if (sessions.isNotEmpty) ids.add('first_quiz');

    if (sessions.any((s) => s.total > 0 && s.score == s.total)) {
      ids.add('perfect_score');
    }

    final subjectCounts = <String, int>{};
    for (final s in sessions) {
      subjectCounts[s.subject] = (subjectCounts[s.subject] ?? 0) + 1;
    }
    if (subjectCounts.length >= 9) ids.add('all_subjects');
    if (subjectCounts.values.any((v) => v >= 5)) ids.add('consistent_5');
    if (subjectCounts.length >= 9) ids.add('explorer');

    if (sessions.any((s) => s.difficulty == 'hard' && s.total > 0 && (s.score / s.total) >= 0.9)) {
      ids.add('hard_master');
    }

    final timedSessions = sessions.where((s) => s.timed).toList();
    if (timedSessions.isNotEmpty) {
      final avg = timedSessions.fold<int>(0, (sum, s) => sum + s.total) / timedSessions.length;
      if (avg <= 8) ids.add('speed_demon');
    }

    final hardWins = sessions.where((s) => s.difficulty == 'hard' && s.total > 0 && (s.score / s.total) >= 0.8).length;
    if (hardWins >= 3) ids.add('hard_hero');

    return ids;
  }
}
