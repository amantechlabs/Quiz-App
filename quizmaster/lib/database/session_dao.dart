import 'package:drift/drift.dart';
import 'db_helper.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [DbSessions, DbSessionAnswers, DbAchievements, DbQuestions, DbProfiles])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<int> createSession({
    required int profileId,
    required String subject,
    required String difficulty,
    required int questionCount,
    required bool timed,
  }) {
    return into(dbSessions).insert(DbSessionsCompanion.insert(
      profileId: profileId,
      subject: subject,
      difficulty: difficulty,
      questionCount: questionCount,
      total: questionCount,
      startedAt: DateTime.now().toIso8601String(),
      completedAt: DateTime.now().toIso8601String(),
      timed: Value(timed),
    ));
  }

  Future<void> insertAnswer({
    required int sessionId,
    required int questionId,
    required int selectedIndex,
    required bool isCorrect,
    required int timeTakenSecs,
  }) {
    return into(dbSessionAnswers).insert(DbSessionAnswersCompanion.insert(
      sessionId: sessionId,
      questionId: questionId,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      timeTakenSecs: timeTakenSecs,
    ));
  }

  Future<void> completeSession({required int sessionId, required int score}) async {
    await (update(dbSessions)..where((t) => t.id.equals(sessionId))).write(
      DbSessionsCompanion(
        score: Value(score),
        completedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<List<DbSession>> recentSessions(int profileId, {int limit = 15}) async {
    return (select(dbSessions)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
  }

  Future<List<DbSessionAnswer>> answersForSession(int sessionId) {
    return (select(dbSessionAnswers)..where((t) => t.sessionId.equals(sessionId))).get();
  }

  Future<List<DbSession>> sessionsForProfile(int profileId) {
    return (select(dbSessions)..where((t) => t.profileId.equals(profileId))).get();
  }

  Future<List<DbAchievement>> achievementsForProfile(int profileId) {
    return (select(dbAchievements)..where((t) => t.profileId.equals(profileId))).get();
  }

  Future<void> unlockAchievement(int profileId, String achievement) async {
    final exists = await (select(dbAchievements)
          ..where((t) => t.profileId.equals(profileId) & t.achievement.equals(achievement)))
        .getSingleOrNull();
    if (exists == null) {
      await into(dbAchievements).insert(DbAchievementsCompanion.insert(
        profileId: profileId,
        achievement: achievement,
        unlockedAt: DateTime.now().toIso8601String(),
      ));
    }
  }

  Future<void> resetProfileData(int profileId) async {
    final sessionIds = await (selectOnly(dbSessions)
          ..addColumns([dbSessions.id])
          ..where(dbSessions.profileId.equals(profileId)))
        .map((row) => row.read(dbSessions.id)!)
        .get();

    if (sessionIds.isNotEmpty) {
      await (delete(dbSessionAnswers)..where((t) => t.sessionId.isIn(sessionIds))).go();
    }
    await (delete(dbAchievements)..where((t) => t.profileId.equals(profileId))).go();
    await (delete(dbSessions)..where((t) => t.profileId.equals(profileId))).go();
  }

  Future<Map<String, int>> subjectScores(int profileId) async {
    final sessions = await sessionsForProfile(profileId);
    final map = <String, int>{};
    for (final s in sessions) {
      map[s.subject] = (map[s.subject] ?? 0) + s.score;
    }
    return map;
  }

  Future<Map<String, double>> subjectAccuracy(int profileId) async {
    final sessions = await sessionsForProfile(profileId);
    final bySubject = <String, List<DbSession>>{};
    for (final s in sessions) {
      bySubject.putIfAbsent(s.subject, () => []).add(s);
    }
    final result = <String, double>{};
    bySubject.forEach((subject, list) {
      final correct = list.fold<int>(0, (sum, s) => sum + s.score);
      final total = list.fold<int>(0, (sum, s) => sum + s.total);
      result[subject] = total == 0 ? 0 : correct / total;
    });
    return result;
  }
}
