import 'dart:async';
import 'package:flutter/foundation.dart';

import '../database/db_helper.dart';
import '../models/question.dart';

class QuizProvider extends ChangeNotifier {
final AppDatabase db;
QuizProvider(this.db);

// ✅ FIXED: Use DbProfile instead of Profile
DbProfile? _activeProfile;

List<Question> _questions = [];
int _currentIndex = 0;
int _score = 0;
int _correct = 0;
int _wrong = 0;
int? _selectedIndex;
bool _isAnswered = false;
bool _loading = false;
bool _timed = false;
int _secondsLeft = 15;
Timer? _timer;
int? _sessionId;
DateTime? _questionStartedAt;
String? _subject;
String? _difficulty;

List<Question> get questions => _questions;
int get currentIndex => _currentIndex;
int get score => _score;
int get correct => _correct;
int get wrong => _wrong;
int? get selectedIndex => _selectedIndex;
bool get isAnswered => _isAnswered;
bool get loading => _loading;
bool get timed => _timed;
int get secondsLeft => _secondsLeft;
int? get sessionId => _sessionId;
Question get currentQuestion => _questions[_currentIndex];
bool get isLastQuestion => _currentIndex == _questions.length - 1;
bool get isReady => _questions.isNotEmpty;

// ✅ FIXED: DbProfile here
void setActiveProfile(DbProfile? profile) {
_activeProfile = profile;
}

Future<void> startQuiz({
required String subject,
required String difficulty,
required int questionCount,
required bool timed,
}) async {
if (_activeProfile == null) return;

```
_loading = true;
notifyListeners();

_subject = subject;
_difficulty = difficulty;
_timed = timed;

final rows = await db.questionDao.getQuestions(
  subject: subject,
  difficulty: difficulty,
  limit: questionCount,
);

_questions = rows
    .map((q) => Question(
          id: q.id,
          subject: q.subject,
          difficulty: q.difficulty,
          questionText: q.questionText,
          options: [q.optionA, q.optionB, q.optionC, q.optionD],
          correctIndex: q.correctIndex,
          explanation: q.explanation,
        ))
    .toList();

_sessionId = await db.sessionDao.createSession(
  profileId: _activeProfile!.id,
  subject: subject,
  difficulty: difficulty,
  questionCount: questionCount,
  timed: timed,
);

_currentIndex = 0;
_score = 0;
_correct = 0;
_wrong = 0;
_selectedIndex = null;
_isAnswered = false;
_secondsLeft = timed ? 15 : 0;
_questionStartedAt = DateTime.now();
_loading = false;
notifyListeners();

_timer?.cancel();
if (timed) {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsLeft <= 1) {
      timer.cancel();
      timeoutCurrentQuestion();
      return;
    }
    _secondsLeft--;
    notifyListeners();
  });
}
```

}

Future<void> selectAnswer(int index) async {
if (_isAnswered || _questions.isEmpty || _sessionId == null) return;

```
_timer?.cancel();
_selectedIndex = index;
_isAnswered = true;

final q = currentQuestion;
final correct = index == q.correctIndex;

if (correct) {
  _score++;
  _correct++;
} else {
  _wrong++;
}

final timeTaken = DateTime.now()
    .difference(_questionStartedAt ?? DateTime.now())
    .inSeconds;

await db.sessionDao.insertAnswer(
  sessionId: _sessionId!,
  questionId: q.id,
  selectedIndex: index,
  isCorrect: correct,
  timeTakenSecs: timeTaken,
);

notifyListeners();
```

}

Future<void> timeoutCurrentQuestion() async {
if (_isAnswered || _questions.isEmpty || _sessionId == null) return;

```
_selectedIndex = -1;
_isAnswered = true;
_wrong++;

final q = currentQuestion;

await db.sessionDao.insertAnswer(
  sessionId: _sessionId!,
  questionId: q.id,
  selectedIndex: -1,
  isCorrect: false,
  timeTakenSecs: 15,
);

notifyListeners();
```

}

void nextQuestion() {
if (_currentIndex < _questions.length - 1) {
_currentIndex++;
_selectedIndex = null;
_isAnswered = false;
_secondsLeft = _timed ? 15 : 0;
_questionStartedAt = DateTime.now();
notifyListeners();
}
}

Future<void> completeQuiz() async {
_timer?.cancel();
if (_sessionId != null) {
await db.sessionDao
.completeSession(sessionId: _sessionId!, score: _score);
}
}

Future<void> disposeQuiz() async {
_timer?.cancel();
}

void reset() {
_timer?.cancel();
_questions = [];
_currentIndex = 0;
_score = 0;
_correct = 0;
_wrong = 0;
_selectedIndex = null;
_isAnswered = false;
_secondsLeft = 15;
_sessionId = null;
_questionStartedAt = null;
notifyListeners();
}
}
