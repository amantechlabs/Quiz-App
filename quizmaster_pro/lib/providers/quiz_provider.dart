import 'package:flutter/material.dart';
import '../database/question_dao.dart';
import '../database/session_dao.dart';
import '../models/question.dart';
import '../models/session.dart';
import '../models/session_answer.dart';

class QuizProvider extends ChangeNotifier {
  // Config
  String subject = '';
  String difficulty = '';
  int questionCount = 10;
  bool timed = true;
  int profileId = 0;

  // State
  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;
  bool isAnswered = false;
  bool isCorrect = false;
  DateTime? _sessionStart;
  int? _questionStart;
  int _sessionId = -1;
  final List<SessionAnswer> _answers = [];

  Question get current => questions[currentIndex];
  bool get isLast => currentIndex == questions.length - 1;
  double get progress => questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  Future<void> startQuiz({
    required String subject,
    required String difficulty,
    required int questionCount,
    required bool timed,
    required int profileId,
  }) async {
    this.subject = subject;
    this.difficulty = difficulty;
    this.questionCount = questionCount;
    this.timed = timed;
    this.profileId = profileId;

    questions = await QuestionDao.getRandom(
      subject: subject,
      difficulty: difficulty,
      limit: questionCount,
    );
    currentIndex = 0;
    score = 0;
    selectedIndex = null;
    isAnswered = false;
    isCorrect = false;
    _sessionStart = DateTime.now();
    _questionStart = DateTime.now().millisecondsSinceEpoch;
    _answers.clear();
    _sessionId = -1;

    notifyListeners();
  }

  void answerQuestion(int optionIndex) {
    if (isAnswered) return;
    selectedIndex = optionIndex;
    isAnswered = true;
    isCorrect = optionIndex == current.correctIndex;
    if (isCorrect) score++;

    final timeTaken = optionIndex == -1
        ? 15 // timed out
        : ((DateTime.now().millisecondsSinceEpoch - (_questionStart ?? 0)) / 1000)
            .round()
            .clamp(0, 999);

    _answers.add(SessionAnswer(
      id: 0,
      sessionId: 0,
      questionId: current.id,
      selectedIndex: optionIndex,
      isCorrect: isCorrect,
      timeTakenSecs: timeTaken,
    ));

    notifyListeners();
  }

  void nextQuestion() {
    if (!isLast) {
      currentIndex++;
      selectedIndex = null;
      isAnswered = false;
      isCorrect = false;
      _questionStart = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    }
  }

  /// Saves session + answers to DB. Returns the saved Session.
  Future<Session> saveSession() async {
    final now = DateTime.now();
    final session = Session(
      id: 0,
      profileId: profileId,
      subject: subject,
      difficulty: difficulty,
      questionCount: questionCount,
      score: score,
      total: questions.length,
      timed: timed,
      startedAt: _sessionStart ?? now,
      completedAt: now,
    );
    final sid = await SessionDao.insertSession(session);
    _sessionId = sid;

    for (final a in _answers) {
      await SessionDao.insertAnswer(SessionAnswer(
        id: 0,
        sessionId: sid,
        questionId: a.questionId,
        selectedIndex: a.selectedIndex,
        isCorrect: a.isCorrect,
        timeTakenSecs: a.timeTakenSecs,
      ));
    }

    return Session(
      id: sid,
      profileId: profileId,
      subject: subject,
      difficulty: difficulty,
      questionCount: questionCount,
      score: score,
      total: questions.length,
      timed: timed,
      startedAt: _sessionStart ?? now,
      completedAt: now,
    );
  }

  List<SessionAnswer> get answers => List.unmodifiable(_answers);

  void reset() {
    questions = [];
    currentIndex = 0;
    score = 0;
    selectedIndex = null;
    isAnswered = false;
    isCorrect = false;
    _answers.clear();
    notifyListeners();
  }
}
