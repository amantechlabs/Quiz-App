class Question {
  final int id;
  final String subject;
  final String difficulty;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const Question({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
