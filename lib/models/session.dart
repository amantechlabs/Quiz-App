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

  String get grade {
    if (percentage >= 90) return 'Outstanding';
    if (percentage >= 70) return 'Great';
    if (percentage >= 50) return 'Not Bad';
    return 'Keep Practicing';
  }

  factory Session.fromMap(Map<String, dynamic> m) => Session(
        id: m['id'] as int,
        profileId: m['profile_id'] as int,
        subject: m['subject'] as String,
        difficulty: m['difficulty'] as String,
        questionCount: m['question_count'] as int,
        score: m['score'] as int,
        total: m['total'] as int,
        timed: (m['timed'] as int) == 1,
        startedAt: DateTime.parse(m['started_at'] as String),
        completedAt: DateTime.parse(m['completed_at'] as String),
      );

  Map<String, dynamic> toInsertMap() => {
        'profile_id': profileId,
        'subject': subject,
        'difficulty': difficulty,
        'question_count': questionCount,
        'score': score,
        'total': total,
        'timed': timed ? 1 : 0,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt.toIso8601String(),
      };
}
