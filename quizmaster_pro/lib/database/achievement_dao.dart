import '../models/achievement.dart';
import 'db_helper.dart';

class AchievementDao {
  static Future<List<String>> getUnlockedIds(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.query('achievements',
        columns: ['achievement', 'unlocked_at'],
        where: 'profile_id = ?',
        whereArgs: [profileId]);
    return rows.map((r) => r['achievement'] as String).toList();
  }

  static Future<Map<String, DateTime>> getUnlockedMap(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.query('achievements',
        where: 'profile_id = ?', whereArgs: [profileId]);
    return {
      for (final r in rows)
        r['achievement'] as String: DateTime.parse(r['unlocked_at'] as String)
    };
  }

  static Future<bool> isUnlocked(int profileId, String achievementId) async {
    final db = await DbHelper.database;
    final rows = await db.query('achievements',
        where: 'profile_id = ? AND achievement = ?',
        whereArgs: [profileId, achievementId],
        limit: 1);
    return rows.isNotEmpty;
  }

  static Future<void> unlock(int profileId, String achievementId) async {
    final already = await isUnlocked(profileId, achievementId);
    if (already) return;
    final db = await DbHelper.database;
    await db.insert('achievements', {
      'profile_id': profileId,
      'achievement': achievementId,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Achievement>> getAllForProfile(int profileId) async {
    final unlockedMap = await getUnlockedMap(profileId);
    return Achievement.all.map((a) {
      a.unlockedAt = unlockedMap[a.id];
      return a;
    }).toList();
  }

  static Future<void> deleteAllForProfile(int profileId) async {
    final db = await DbHelper.database;
    await db.delete('achievements', where: 'profile_id = ?', whereArgs: [profileId]);
  }
}
