class Question {
  final int id;
  final String subject;
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int correctIndex; // 0–3
  final String explanation;

  const Question({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctIndex,
    this.explanation = '',
  });

  List<String> get options => [optionA, optionB, optionC, optionD];

  factory Question.fromMap(Map<String, dynamic> m) => Question(
        id: m['id'] as int,
        subject: m['subject'] as String,
        difficulty: m['difficulty'] as String,
        questionText: m['question_text'] as String,
        optionA: m['option_a'] as String,
        optionB: m['option_b'] as String,
        optionC: m['option_c'] as String,
        optionD: m['option_d'] as String,
        correctIndex: m['correct_index'] as int,
        explanation: (m['explanation'] as String?) ?? '',
      );

  factory Question.fromJson(Map<String, dynamic> j, int id) {
    final opts = List<String>.from(j['options'] as List);
    return Question(
      id: id,
      subject: j['subject'] as String,
      difficulty: j['difficulty'] as String,
      questionText: j['question'] as String,
      optionA: opts[0],
      optionB: opts[1],
      optionC: opts[2],
      optionD: opts[3],
      correctIndex: j['correctIndex'] as int,
      explanation: (j['explanation'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'subject': subject,
        'difficulty': difficulty,
        'question_text': questionText,
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_index': correctIndex,
        'explanation': explanation,
      };
}
