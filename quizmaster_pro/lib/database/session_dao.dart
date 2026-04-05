import '../models/session.dart';
import '../models/session_answer.dart';
import '../models/question.dart';
import 'db_helper.dart';

class SessionDao {
  static Future<int> insertSession(Session s) async {
    final db = await DbHelper.database;
    return db.insert('sessions', s.toInsertMap());
  }

  static Future<void> insertAnswer(SessionAnswer a) async {
    final db = await DbHelper.database;
    await db.insert('session_answers', a.toInsertMap());
  }

  /// Last 15 sessions for a profile
  static Future<List<Session>> getHistory(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.query(
      'sessions',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'completed_at DESC',
      limit: 15,
    );
    return rows.map(Session.fromMap).toList();
  }

  /// All answers for a session, with questions joined
  static Future<List<SessionAnswer>> getAnswersForSession(int sessionId) async {
    final db = await DbHelper.database;
    final rows = await db.rawQuery('''
      SELECT sa.*, q.subject, q.difficulty, q.question_text,
             q.option_a, q.option_b, q.option_c, q.option_d,
             q.correct_index, q.explanation
      FROM session_answers sa
      JOIN questions q ON sa.question_id = q.id
      WHERE sa.session_id = ?
    ''', [sessionId]);

    return rows.map((r) {
      final q = Question(
        id: r['id'] as int,
        subject: r['subject'] as String,
        difficulty: r['difficulty'] as String,
        questionText: r['question_text'] as String,
        optionA: r['option_a'] as String,
        optionB: r['option_b'] as String,
        optionC: r['option_c'] as String,
        optionD: r['option_d'] as String,
        correctIndex: r['correct_index'] as int,
        explanation: (r['explanation'] as String?) ?? '',
      );
      return SessionAnswer(
        id: r['id'] as int,
        sessionId: r['session_id'] as int,
        questionId: r['question_id'] as int,
        selectedIndex: r['selected_index'] as int,
        isCorrect: (r['is_correct'] as int) == 1,
        timeTakenSecs: r['time_taken_secs'] as int,
        question: q,
      );
    }).toList();
  }

  /// Accuracy per subject for stats
  static Future<Map<String, double>> getSubjectAccuracy(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.rawQuery('''
      SELECT s.subject,
             SUM(s.score) as total_correct,
             SUM(s.total) as total_questions
      FROM sessions s
      WHERE s.profile_id = ?
      GROUP BY s.subject
    ''', [profileId]);

    final Map<String, double> result = {};
    for (final r in rows) {
      final correct = (r['total_correct'] as int?) ?? 0;
      final total = (r['total_questions'] as int?) ?? 0;
      result[r['subject'] as String] = total == 0 ? 0 : correct / total * 100;
    }
    return result;
  }

  /// Overall stats
  static Future<Map<String, dynamic>> getOverallStats(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) as total_sessions,
             SUM(total) as total_questions,
             SUM(score) as total_correct,
             MAX(CAST(score AS REAL) / CAST(total AS REAL) * 100) as best_score
      FROM sessions WHERE profile_id = ?
    ''', [profileId]);
    final r = rows.first;
    return {
      'total_sessions': (r['total_sessions'] as int?) ?? 0,
      'total_questions': (r['total_questions'] as int?) ?? 0,
      'total_correct': (r['total_correct'] as int?) ?? 0,
      'best_score': (r['best_score'] as double?) ?? 0.0,
    };
  }

  /// Difficulty accuracy
  static Future<Map<String, double>> getDifficultyAccuracy(int profileId) async {
    final db = await DbHelper.database;
    final rows = await db.rawQuery('''
      SELECT difficulty,
             SUM(score) as correct,
             SUM(total) as total
      FROM sessions WHERE profile_id = ?
      GROUP BY difficulty
    ''', [profileId]);
    final Map<String, double> result = {};
    for (final r in rows) {
      final c = (r['correct'] as int?) ?? 0;
      final t = (r['total'] as int?) ?? 0;
      result[r['difficulty'] as String] = t == 0 ? 0 : c / t * 100;
    }
    return result;
  }

  static Future<void> deleteAllForProfile(int profileId) async {
    final db = await DbHelper.database;
    await db.delete('sessions', where: 'profile_id = ?', whereArgs: [profileId]);
  }
}
