import 'package:drift/drift.dart';
import 'db_helper.dart';

part 'question_dao.g.dart';

@DriftAccessor(tables: [DbQuestions])
class QuestionDao extends DatabaseAccessor<AppDatabase> with _$QuestionDaoMixin {
  QuestionDao(super.db);

  Future<List<DbQuestion>> getQuestions({
    required String subject,
    required String difficulty,
    required int limit,
  }) async {
    final rows = await (select(dbQuestions)
          ..where((t) => t.subject.equals(subject) & t.difficulty.equals(difficulty))
          ..limit(limit))
        .get();
    rows.shuffle();
    return rows;
  }

  Future<List<String>> getSubjects() async {
    final query = selectOnly(dbQuestions)
      ..addColumns([dbQuestions.subject])
      ..groupBy([dbQuestions.subject]);
    final rows = await query.map((row) => row.read(dbQuestions.subject)!).get();
    return rows;
  }

  Future<int> countBySubject(String subject) {
    return (select(dbQuestions)..where((t) => t.subject.equals(subject))).get().then((v) => v.length);
  }
}
