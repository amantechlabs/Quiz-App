import 'package:sqflite/sqflite.dart';
import '../models/question.dart';
import 'db_helper.dart';

class QuestionDao {
  static Future<List<Question>> getRandom({
    required String subject,
    required String difficulty,
    required int limit,
  }) async {
    final db = await DbHelper.database;
    final rows = await db.rawQuery(
      '''SELECT * FROM questions
         WHERE subject = ? AND difficulty = ?
         ORDER BY RANDOM() LIMIT ?''',
      [subject, difficulty, limit],
    );
    return rows.map(Question.fromMap).toList();
  }

  static Future<int> count() async {
    final db = await DbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM questions');
    return (res.first['c'] as int?) ?? 0;
  }

  static Future<int> countBySubjectDifficulty(String subject, String difficulty) async {
    final db = await DbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM questions WHERE subject = ? AND difficulty = ?',
      [subject, difficulty],
    );
    return (res.first['c'] as int?) ?? 0;
  }

  static Future<void> batchInsert(List<Map<String, dynamic>> rows) async {
    final db = await DbHelper.database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('questions', row, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
