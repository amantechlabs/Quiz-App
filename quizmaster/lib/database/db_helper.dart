import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'profile_dao.dart';
import 'question_dao.dart';
import 'session_dao.dart';

part 'db_helper.g.dart';

class DbProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get avatar => text()();
  TextColumn get createdAt => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
}

class DbQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subject => text()();
  TextColumn get difficulty => text()();
  TextColumn get questionText => text()();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  IntColumn get correctIndex => integer()();
  TextColumn get explanation => text()();
}

class DbSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(DbProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get subject => text()();
  TextColumn get difficulty => text()();
  IntColumn get questionCount => integer()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  IntColumn get total => integer()();
  BoolColumn get timed => boolean().withDefault(const Constant(false))();
  TextColumn get startedAt => text()();
  TextColumn get completedAt => text()();
}

class DbSessionAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(DbSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionId => integer().references(DbQuestions, #id, onDelete: KeyAction.cascade)();
  IntColumn get selectedIndex => integer()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get timeTakenSecs => integer()();
}

class DbAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(DbProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get achievement => text()();
  TextColumn get unlockedAt => text()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'quizmaster_pro.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [DbProfiles, DbQuestions, DbSessions, DbSessionAnswers, DbAchievements],
  daos: [ProfileDao, QuestionDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
