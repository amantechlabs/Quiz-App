class SessionAnswer {
  final int id;
  final int sessionId;
  final int questionId;
  final int selectedIndex;
  final bool isCorrect;
  final int timeTakenSecs;

  const SessionAnswer({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeTakenSecs,
  });
}
