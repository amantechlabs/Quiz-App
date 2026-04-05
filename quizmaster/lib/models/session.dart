class Session {
  final int id;
  final int profileId;
  final String subject;
  final String difficulty;
  final int questionCount;
  final int score;
  final int total;
  final bool timed;
  final DateTime startedAt;
  final DateTime completedAt;

  const Session({
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

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}
