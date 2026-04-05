import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;
  static const int _version = 1;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quizmaster_pro.db');
    return openDatabase(path, version: _version, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        avatar     TEXT    NOT NULL,
        created_at TEXT    NOT NULL,
        is_active  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        subject       TEXT    NOT NULL,
        difficulty    TEXT    NOT NULL,
        question_text TEXT    NOT NULL,
        option_a      TEXT    NOT NULL,
        option_b      TEXT    NOT NULL,
        option_c      TEXT    NOT NULL,
        option_d      TEXT    NOT NULL,
        correct_index INTEGER NOT NULL,
        explanation   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id     INTEGER NOT NULL,
        subject        TEXT    NOT NULL,
        difficulty     TEXT    NOT NULL,
        question_count INTEGER NOT NULL,
        score          INTEGER NOT NULL,
        total          INTEGER NOT NULL,
        timed          INTEGER NOT NULL DEFAULT 0,
        started_at     TEXT    NOT NULL,
        completed_at   TEXT    NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE session_answers (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id      INTEGER NOT NULL,
        question_id     INTEGER NOT NULL,
        selected_index  INTEGER NOT NULL,
        is_correct      INTEGER NOT NULL,
        time_taken_secs INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id   INTEGER NOT NULL,
        achievement  TEXT    NOT NULL,
        unlocked_at  TEXT    NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_questions_subject_diff ON questions(subject, difficulty)');
    await db.execute('CREATE INDEX idx_sessions_profile ON sessions(profile_id)');
    await db.execute('CREATE INDEX idx_answers_session ON session_answers(session_id)');
  }
}
