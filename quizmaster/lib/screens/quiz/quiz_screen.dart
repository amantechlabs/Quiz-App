import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/option_button.dart';
import '../../widgets/timer_bar.dart';
import '../result/result_screen.dart';
import '../quiz/review_screen.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String difficulty;
  final int count;
  final bool timed;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.difficulty,
    required this.count,
    required this.timed,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = context.read<ProfileProvider>().activeProfile;
    if (profile == null) return;
    await context.read<QuizProvider>().startQuiz(
      subject: widget.subject,
      difficulty: widget.difficulty,
      questionCount: widget.count,
      timed: widget.timed,
    );
    if (!mounted) return;
    setState(() => _booting = false);
  }

  Future<void> _finishIfNeeded() async {
    final quiz = context.read<QuizProvider>();
    await quiz.completeQuiz();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: quiz.score,
          total: quiz.questions.length,
          sessionId: quiz.sessionId ?? 0,
          subject: widget.subject,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (_booting || quiz.loading || !quiz.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = quiz.currentQuestion;
    final reveal = quiz.isAnswered;

    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.currentIndex + 1}/${quiz.questions.length}'),
        actions: [
          if (widget.timed) Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${quiz.secondsLeft}s', style: const TextStyle(fontWeight: FontWeight.w700))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.timed) TimerBar(secondsLeft: quiz.secondsLeft, totalSeconds: 15),
          const SizedBox(height: 18),
          Text(question.questionText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          ...List.generate(question.options.length, (i) {
            return OptionButton(
              text: question.options[i],
              selected: quiz.selectedIndex == i,
              correct: question.correctIndex == i,
              reveal: reveal,
              onTap: () async {
                await context.read<QuizProvider>().selectAnswer(i);
              },
            );
          }),
          const SizedBox(height: 10),
          if (reveal) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(question.explanation),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (quiz.isLastQuestion) {
                  await _finishIfNeeded();
                } else {
                  context.read<QuizProvider>().nextQuestion();
                }
              },
              child: Text(quiz.isLastQuestion ? 'Finish Quiz' : 'Next Question'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewScreen(sessionId: quiz.sessionId ?? 0)),
                );
              },
              child: const Text('Review Wrong Answers'),
            ),
          ],
        ],
      ),
    );
  }
}
