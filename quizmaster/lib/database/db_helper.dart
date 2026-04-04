import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DbProfile {
  final int id;
  final String name;
  final String avatar;
  final String createdAt;
  final bool isActive;

  const DbProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.createdAt,
    required this.isActive,
  });

  factory DbProfile.fromJson(Map<String, dynamic> json) => DbProfile(
        id: json['id'] as int,
        name: json['name'] as String,
        avatar: json['avatar'] as String,
        createdAt: json['createdAt'] as String,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'createdAt': createdAt,
        'isActive': isActive,
      };
}

class DbQuestion {
  final int id;
  final String subject;
  final String difficulty;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int correctIndex;
  final String explanation;

  const DbQuestion({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctIndex,
    required this.explanation,
  });

  factory DbQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    return DbQuestion(
      id: json['id'] as int,
      subject: json['subject'] as String,
      difficulty: json['difficulty'] as String,
      questionText: (json['question'] ?? json['questionText']) as String,
      optionA: options[0],
      optionB: options[1],
      optionC: options[2],
      optionD: options[3],
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'difficulty': difficulty,
        'question': questionText,
        'options': [optionA, optionB, optionC, optionD],
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class DbSession {
  final int id;
  final int profileId;
  final String subject;
  final String difficulty;
  final int questionCount;
  final int score;
  final int total;
  final bool timed;
  final String startedAt;
  final String completedAt;

  const DbSession({
    required this.id,
    required this.profileId,
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    required this.score,
    required this.total,
    required this.timed,
    required this.startedAt,
    required this.completedAt,
  });

  factory DbSession.fromJson(Map<String, dynamic> json) => DbSession(
        id: json['id'] as int,
        profileId: json['profileId'] as int,
        subject: json['subject'] as String,
        difficulty: json['difficulty'] as String,
        questionCount: json['questionCount'] as int,
        score: json['score'] as int,
        total: json['total'] as int,
        timed: json['timed'] as bool,
        startedAt: json['startedAt'] as String,
        completedAt: json['completedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'subject': subject,
        'difficulty': difficulty,
        'questionCount': questionCount,
        'score': score,
        'total': total,
        'timed': timed,
        'startedAt': startedAt,
        'completedAt': completedAt,
      };

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}

class DbSessionAnswer {
  final int id;
  final int sessionId;
  final int questionId;
  final int selectedIndex;
  final bool isCorrect;
  final int timeTakenSecs;

  const DbSessionAnswer({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeTakenSecs,
  });

  factory DbSessionAnswer.fromJson(Map<String, dynamic> json) => DbSessionAnswer(
        id: json['id'] as int,
        sessionId: json['sessionId'] as int,
        questionId: json['questionId'] as int,
        selectedIndex: json['selectedIndex'] as int,
        isCorrect: json['isCorrect'] as bool,
        timeTakenSecs: json['timeTakenSecs'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'isCorrect': isCorrect,
        'timeTakenSecs': timeTakenSecs,
      };
}

class DbAchievement {
  final int id;
  final int profileId;
  final String achievement;
  final String unlockedAt;

  const DbAchievement({
    required this.id,
    required this.profileId,
    required this.achievement,
    required this.unlockedAt,
  });

  factory DbAchievement.fromJson(Map<String, dynamic> json) => DbAchievement(
        id: json['id'] as int,
        profileId: json['profileId'] as int,
        achievement: json['achievement'] as String,
        unlockedAt: json['unlockedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'achievement': achievement,
        'unlockedAt': unlockedAt,
      };
}

Future<File> _dbFile(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'quizmaster_data'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  return File(p.join(folder.path, name));
}

Future<List<T>> _readList<T>(String fileName, T Function(Map<String, dynamic>) fromJson) async {
  final file = await _dbFile(fileName);
  if (!await file.exists()) return <T>[];
  final raw = await file.readAsString();
  if (raw.trim().isEmpty) return <T>[];
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded.map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList();
}

Future<void> _writeList<T>(String fileName, List<T> items, Map<String, dynamic> Function(T) toJson) async {
  final file = await _dbFile(fileName);
  await file.writeAsString(jsonEncode(items.map(toJson).toList()));
}

class AppDatabase {
  AppDatabase()
      : profileDao = ProfileDao._(null),
        questionDao = QuestionDao._(null),
        sessionDao = SessionDao._(null) {
    profileDao._db = this;
    questionDao._db = this;
    sessionDao._db = this;
    _ready = _load();
  }

  late final Future<void> _ready;

  final ProfileDao profileDao;
  final QuestionDao questionDao;
  final SessionDao sessionDao;

  List<DbProfile> _profiles = [];
  List<DbQuestion> _questions = [];
  List<DbSession> _sessions = [];
  List<DbSessionAnswer> _answers = [];
  List<DbAchievement> _achievements = [];

  Future<void> _load() async {
    _profiles = await _readList('profiles.json', DbProfile.fromJson);
    _questions = await _readList('questions.json', DbQuestion.fromJson);
    _sessions = await _readList('sessions.json', DbSession.fromJson);
    _answers = await _readList('answers.json', DbSessionAnswer.fromJson);
    _achievements = await _readList('achievements.json', DbAchievement.fromJson);
  }

  Future<void> _saveProfiles() => _writeList('profiles.json', _profiles, (e) => e.toJson());
  Future<void> _saveQuestions() => _writeList('questions.json', _questions, (e) => e.toJson());
  Future<void> _saveSessions() => _writeList('sessions.json', _sessions, (e) => e.toJson());
  Future<void> _saveAnswers() => _writeList('answers.json', _answers, (e) => e.toJson());
  Future<void> _saveAchievements() => _writeList('achievements.json', _achievements, (e) => e.toJson());

  int _nextId<T>(List<T> items, int Function(T item) getId) {
    var maxId = 0;
    for (final item in items) {
      final id = getId(item);
      if (id > maxId) maxId = id;
    }
    return maxId + 1;
  }

  Future<void> replaceQuestions(List<DbQuestion> questions) async {
    await _ready;
    _questions = questions;
    await _saveQuestions();
  }

  Future<int> _createProfile({required String name, required String avatar}) async {
    await _ready;
    _profiles = [
      for (final p in _profiles)
        DbProfile(id: p.id, name: p.name, avatar: p.avatar, createdAt: p.createdAt, isActive: false)
    ];
    final id = _nextId(_profiles, (p) => p.id);
    _profiles.add(DbProfile(id: id, name: name, avatar: avatar, createdAt: DateTime.now().toIso8601String(), isActive: true));
    await _saveProfiles();
    return id;
  }

  Future<void> _setActiveProfile(int id) async {
    await _ready;
    _profiles = _profiles
        .map((p) => DbProfile(id: p.id, name: p.name, avatar: p.avatar, createdAt: p.createdAt, isActive: p.id == id))
        .toList();
    await _saveProfiles();
  }

  Future<void> _renameProfile(int id, String name) async {
    await _ready;
    _profiles = [
      for (final p in _profiles)
        if (p.id == id)
          DbProfile(id: p.id, name: name, avatar: p.avatar, createdAt: p.createdAt, isActive: p.isActive)
        else
          p
    ];
    await _saveProfiles();
  }

  Future<void> _updateAvatar(int id, String avatar) async {
    await _ready;
    _profiles = [
      for (final p in _profiles)
        if (p.id == id)
          DbProfile(id: p.id, name: p.name, avatar: avatar, createdAt: p.createdAt, isActive: p.isActive)
        else
          p
    ];
    await _saveProfiles();
  }

  Future<void> _deleteProfile(int id) async {
    await _ready;
    final sessionIds = _sessions.where((s) => s.profileId == id).map((s) => s.id).toSet();
    _profiles.removeWhere((p) => p.id == id);
    _sessions.removeWhere((s) => s.profileId == id);
    _answers.removeWhere((a) => sessionIds.contains(a.sessionId));
    _achievements.removeWhere((a) => a.profileId == id);

    if (_profiles.isNotEmpty && _profiles.every((p) => !p.isActive)) {
      final firstId = _profiles.first.id;
      _profiles = _profiles
          .map((p) => DbProfile(id: p.id, name: p.name, avatar: p.avatar, createdAt: p.createdAt, isActive: p.id == firstId))
          .toList();
    }

    await _saveProfiles();
    await _saveSessions();
    await _saveAnswers();
    await _saveAchievements();
  }

  Future<void> _resetProfileData(int profileId) async {
    await _ready;
    final sessionIds = _sessions.where((s) => s.profileId == profileId).map((s) => s.id).toSet();
    _answers.removeWhere((a) => sessionIds.contains(a.sessionId));
    _achievements.removeWhere((a) => a.profileId == profileId);
    _sessions.removeWhere((s) => s.profileId == profileId);
    await _saveSessions();
    await _saveAnswers();
    await _saveAchievements();
  }

  Future<List<DbProfile>> _getAllProfiles() async {
    await _ready;
    final list = [..._profiles];
    list.sort((a, b) => (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0));
    return list;
  }

  Future<DbProfile?> _getActiveProfile() async {
    await _ready;
    for (final p in _profiles) {
      if (p.isActive) return p;
    }
    return null;
  }

  Future<List<DbQuestion>> _getQuestions({required String subject, required String difficulty, required int limit}) async {
    await _ready;
    final rows = _questions.where((q) => q.subject == subject && q.difficulty == difficulty).toList();
    rows.shuffle();
    return rows.take(limit).toList();
  }

  Future<List<String>> _getSubjects() async {
    await _ready;
    final subjects = _questions.map((q) => q.subject).toSet().toList();
    subjects.sort();
    return subjects;
  }

  Future<int> _countBySubject(String subject) async {
    await _ready;
    return _questions.where((q) => q.subject == subject).length;
  }

  Future<int> _createSession({required int profileId, required String subject, required String difficulty, required int questionCount, required bool timed}) async {
    await _ready;
    final now = DateTime.now().toIso8601String();
    final id = _nextId(_sessions, (s) => s.id);
    _sessions.add(DbSession(id: id, profileId: profileId, subject: subject, difficulty: difficulty, questionCount: questionCount, score: 0, total: questionCount, timed: timed, startedAt: now, completedAt: now));
    await _saveSessions();
    return id;
  }

  Future<void> _insertAnswer({required int sessionId, required int questionId, required int selectedIndex, required bool isCorrect, required int timeTakenSecs}) async {
    await _ready;
    final id = _nextId(_answers, (a) => a.id);
    _answers.add(DbSessionAnswer(id: id, sessionId: sessionId, questionId: questionId, selectedIndex: selectedIndex, isCorrect: isCorrect, timeTakenSecs: timeTakenSecs));
    await _saveAnswers();
  }

  Future<void> _completeSession({required int sessionId, required int score}) async {
    await _ready;
    _sessions = [
      for (final s in _sessions)
        if (s.id == sessionId)
          DbSession(id: s.id, profileId: s.profileId, subject: s.subject, difficulty: s.difficulty, questionCount: s.questionCount, score: score, total: s.total, timed: s.timed, startedAt: s.startedAt, completedAt: DateTime.now().toIso8601String())
        else
          s
    ];
    await _saveSessions();
  }

  Future<List<DbSession>> _recentSessions(int profileId, {int limit = 15}) async {
    await _ready;
    final rows = _sessions.where((s) => s.profileId == profileId).toList()
      ..sort((a, b) => DateTime.parse(b.completedAt).compareTo(DateTime.parse(a.completedAt)));
    return rows.take(limit).toList();
  }

  Future<List<DbSessionAnswer>> _answersForSession(int sessionId) async {
    await _ready;
    return _answers.where((a) => a.sessionId == sessionId).toList();
  }

  Future<List<DbSession>> _sessionsForProfile(int profileId) async {
    await _ready;
    return _sessions.where((s) => s.profileId == profileId).toList();
  }

  Future<List<DbAchievement>> _achievementsForProfile(int profileId) async {
    await _ready;
    return _achievements.where((a) => a.profileId == profileId).toList();
  }

  Future<void> _unlockAchievement(int profileId, String achievement) async {
    await _ready;
    if (_achievements.any((a) => a.profileId == profileId && a.achievement == achievement)) return;
    final id = _nextId(_achievements, (a) => a.id);
    _achievements.add(DbAchievement(id: id, profileId: profileId, achievement: achievement, unlockedAt: DateTime.now().toIso8601String()));
    await _saveAchievements();
  }

  Future<void> _resetProfileSessions(int profileId) async => _resetProfileData(profileId);

  Future<Map<String, int>> _subjectScores(int profileId) async {
    final sessions = await _sessionsForProfile(profileId);
    final map = <String, int>{};
    for (final s in sessions) {
      map[s.subject] = (map[s.subject] ?? 0) + s.score;
    }
    return map;
  }

  Future<Map<String, double>> _subjectAccuracy(int profileId) async {
    final sessions = await _sessionsForProfile(profileId);
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

class ProfileDao {
  AppDatabase? _db;
  ProfileDao._(this._db);
  AppDatabase get _database => _db!;

  Future<List<DbProfile>> getAllProfiles() => _database._getAllProfiles();
  Future<DbProfile?> getActiveProfile() => _database._getActiveProfile();
  Future<int> createProfile({required String name, required String avatar}) => _database._createProfile(name: name, avatar: avatar);
  Future<void> setActiveProfile(int id) => _database._setActiveProfile(id);
  Future<void> renameProfile(int id, String name) => _database._renameProfile(id, name);
  Future<void> updateAvatar(int id, String avatar) => _database._updateAvatar(id, avatar);
  Future<void> deleteProfile(int id) => _database._deleteProfile(id);
  Future<void> resetProfileData(int profileId) => _database._resetProfileData(profileId);
}

class QuestionDao {
  AppDatabase? _db;
  QuestionDao._(this._db);
  AppDatabase get _database => _db!;

  Future<List<DbQuestion>> getQuestions({required String subject, required String difficulty, required int limit}) => _database._getQuestions(subject: subject, difficulty: difficulty, limit: limit);
  Future<List<String>> getSubjects() => _database._getSubjects();
  Future<int> countBySubject(String subject) => _database._countBySubject(subject);
  Future<void> replaceAll(List<DbQuestion> questions) => _database.replaceQuestions(questions);
}

class SessionDao {
  AppDatabase? _db;
  SessionDao._(this._db);
  AppDatabase get _database => _db!;

  Future<int> createSession({required int profileId, required String subject, required String difficulty, required int questionCount, required bool timed}) => _database._createSession(profileId: profileId, subject: subject, difficulty: difficulty, questionCount: questionCount, timed: timed);
  Future<void> insertAnswer({required int sessionId, required int questionId, required int selectedIndex, required bool isCorrect, required int timeTakenSecs}) => _database._insertAnswer(sessionId: sessionId, questionId: questionId, selectedIndex: selectedIndex, isCorrect: isCorrect, timeTakenSecs: timeTakenSecs);
  Future<void> completeSession({required int sessionId, required int score}) => _database._completeSession(sessionId: sessionId, score: score);
  Future<List<DbSession>> recentSessions(int profileId, {int limit = 15}) => _database._recentSessions(profileId, limit: limit);
  Future<List<DbSessionAnswer>> answersForSession(int sessionId) => _database._answersForSession(sessionId);
  Future<List<DbSession>> sessionsForProfile(int profileId) => _database._sessionsForProfile(profileId);
  Future<List<DbAchievement>> achievementsForProfile(int profileId) => _database._achievementsForProfile(profileId);
  Future<void> unlockAchievement(int profileId, String achievement) => _database._unlockAchievement(profileId, achievement);
  Future<void> resetProfileData(int profileId) => _database._resetProfileSessions(profileId);
  Future<Map<String, int>> subjectScores(int profileId) => _database._subjectScores(profileId);
  Future<Map<String, double>> subjectAccuracy(int profileId) => _database._subjectAccuracy(profileId);
}
