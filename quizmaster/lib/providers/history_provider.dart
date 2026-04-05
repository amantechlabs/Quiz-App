import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';

class HistoryProvider extends ChangeNotifier {
  final AppDatabase db;
  HistoryProvider(this.db);

  Future<List<DbSession>> recentSessions(int profileId) => db.sessionDao.recentSessions(profileId);
  Future<List<DbSessionAnswer>> answersForSession(int sessionId) => db.sessionDao.answersForSession(sessionId);
  Future<List<DbSession>> sessionsForProfile(int profileId) => db.sessionDao.sessionsForProfile(profileId);
  Future<List<DbAchievement>> achievementsForProfile(int profileId) => db.sessionDao.achievementsForProfile(profileId);
}
