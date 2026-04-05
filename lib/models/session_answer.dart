import 'question.dart';

class SessionAnswer {
  final int id;
  final int sessionId;
  final int questionId;
  final int selectedIndex; // -1 if timed out
  final bool isCorrect;
  final int timeTakenSecs;
  final Question? question; // populated on joins

  const SessionAnswer({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeTakenSecs,
    this.question,
  });

  factory SessionAnswer.fromMap(Map<String, dynamic> m, {Question? question}) =>
      SessionAnswer(
        id: m['id'] as int,
        sessionId: m['session_id'] as int,
        questionId: m['question_id'] as int,
        selectedIndex: m['selected_index'] as int,
        isCorrect: (m['is_correct'] as int) == 1,
        timeTakenSecs: m['time_taken_secs'] as int,
        question: question,
      );

  Map<String, dynamic> toInsertMap() => {
        'session_id': sessionId,
        'question_id': questionId,
        'selected_index': selectedIndex,
        'is_correct': isCorrect ? 1 : 0,
        'time_taken_secs': timeTakenSecs,
      };
}
