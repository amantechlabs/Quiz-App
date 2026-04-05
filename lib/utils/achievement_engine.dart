import '../database/achievement_dao.dart';
import '../database/db_helper.dart';
import '../models/session.dart';
import '../models/session_answer.dart';

class AchievementEngine {
  static const Set<String> allSubjects = {
    'Geography', 'History', 'Political Science', 'Physics',
    'Biology', 'Chemistry', 'Mathematics', 'General Knowledge',
    'General Science',
  };

  static Future<List<String>> evaluate({
    required int profileId,
    required Session session,
    required List<SessionAnswer> answers,
  }) async {
    final List<String> newlyUnlocked = [];

    Future<void> tryUnlock(String id) async {
      final already = await AchievementDao.isUnlocked(profileId, id);
      if (!already) {
        await AchievementDao.unlock(profileId, id);
        newlyUnlocked.add(id);
      }
    }

    final allSessions = await _getAllSessions(profileId);

    await tryUnlock('first_quiz');

    if (session.score == session.total) await tryUnlock('perfect_score');

    int streak = 0;
    for (final a in answers) {
      if (a.isCorrect) { streak++; if (streak >= 5) { await tryUnlock('streak_5'); break; } }
      else { streak = 0; }
    }

    final played = allSessions.map((s) => s.subject).toSet();
    if (played.containsAll(allSubjects)) {
      await tryUnlock('all_subjects');
      await tryUnlock('explorer');
    }

    if (session.difficulty == 'hard' && session.percentage >= 90) await tryUnlock('hard_master');

    if (session.timed && answers.isNotEmpty) {
      final avg = answers.fold(0, (s, a) => s + a.timeTakenSecs) / answers.length;
      if (avg < 8) await tryUnlock('speed_demon');
    }

    final subjectCount = allSessions.where((s) => s.subject == session.subject).length;
    if (subjectCount >= 5) await tryUnlock('consistent_5');

    final hard = allSessions.where((s) => s.difficulty == 'hard').toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (hard.length >= 3 && hard.take(3).every((s) => s.percentage >= 80)) {
      await tryUnlock('hard_hero');
    }

    return newlyUnlocked;
  }

  static Future<List<Session>> _getAllSessions(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.query('sessions',
        where: 'profile_id = ?', whereArgs: [profileId], orderBy: 'completed_at DESC');
    return rows.map(Session.fromMap).toList();
  }
}
