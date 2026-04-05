class Achievement {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final String unlockHint;
  DateTime? unlockedAt; // null = locked

  Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlockHint,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  static final List<Achievement> all = [
    Achievement(
      id: 'first_quiz',
      title: 'First Quiz',
      emoji: '🎯',
      description: 'Completed your very first quiz',
      unlockHint: 'Complete any quiz',
    ),
    Achievement(
      id: 'perfect_score',
      title: 'Perfect Score',
      emoji: '💯',
      description: 'Scored 100% on a quiz',
      unlockHint: 'Answer all questions correctly in one quiz',
    ),
    Achievement(
      id: 'streak_5',
      title: 'On Fire',
      emoji: '🔥',
      description: '5 correct answers in a row in a single session',
      unlockHint: 'Get 5 consecutive correct answers',
    ),
    Achievement(
      id: 'all_subjects',
      title: 'Scholar',
      emoji: '📚',
      description: 'Completed a quiz in all 9 subjects',
      unlockHint: 'Play at least one quiz in every subject',
    ),
    Achievement(
      id: 'hard_master',
      title: 'Genius',
      emoji: '🧠',
      description: 'Scored 90%+ on a Hard difficulty quiz',
      unlockHint: 'Score 90% or more on Hard mode',
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      emoji: '🏃',
      description: 'Finished a timed quiz averaging under 8s per question',
      unlockHint: 'Answer quickly — average under 8 seconds per question',
    ),
    Achievement(
      id: 'consistent_5',
      title: 'Consistent',
      emoji: '📅',
      description: 'Completed 5 sessions in the same subject',
      unlockHint: 'Play 5 quizzes in any single subject',
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorer',
      emoji: '🌍',
      description: 'Played all 9 subjects at least once',
      unlockHint: 'Try every subject at least once',
    ),
    Achievement(
      id: 'hard_hero',
      title: 'Hard Mode Hero',
      emoji: '⚡',
      description: 'Won 3 Hard quizzes scoring 80%+ in a row',
      unlockHint: 'Score 80%+ on 3 consecutive Hard quizzes',
    ),
  ];
}
