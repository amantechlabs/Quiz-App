class AppConstants {
  static const subjects = <Map<String, dynamic>>[
    {'name': 'Geography', 'emoji': '🌍'},
    {'name': 'History', 'emoji': '🏛️'},
    {'name': 'Political Science', 'emoji': '🗳️'},
    {'name': 'Physics', 'emoji': '⚛️'},
    {'name': 'Biology', 'emoji': '🧬'},
    {'name': 'Chemistry', 'emoji': '🧪'},
    {'name': 'Mathematics', 'emoji': '➗'},
    {'name': 'General Knowledge', 'emoji': '📘'},
    {'name': 'General Science', 'emoji': '🔭'},
  ];

  static const avatars = ['🙂', '😄', '😎', '🤓', '🧠', '👩‍🎓', '👨‍🎓', '🦉', '🐯', '🦊', '🐱', '🐼'];

  static const difficulties = ['easy', 'medium', 'hard'];

  static const achievementDefs = <Map<String, String>>[
    {'id': 'first_quiz', 'title': 'First Quiz', 'hint': 'Complete your first quiz.'},
    {'id': 'perfect_score', 'title': 'Perfect Score', 'hint': 'Score 100% on any quiz.'},
    {'id': 'streak_5', 'title': 'On Fire', 'hint': 'Get 5 correct answers in a row.'},
    {'id': 'all_subjects', 'title': 'Scholar', 'hint': 'Play all 9 subjects at least once.'},
    {'id': 'hard_master', 'title': 'Genius', 'hint': 'Score 90%+ on any hard quiz.'},
    {'id': 'speed_demon', 'title': 'Speed Demon', 'hint': 'Finish a timed quiz averaging under 8s.'},
    {'id': 'consistent_5', 'title': 'Consistent', 'hint': 'Complete 5 sessions in one subject.'},
    {'id': 'explorer', 'title': 'Explorer', 'hint': 'Play all 9 subjects.'},
    {'id': 'hard_hero', 'title': 'Hard Mode Hero', 'hint': 'Win 3 hard quizzes of 80%+ in a row.'},
  ];
}
