import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/theme.dart';
import '../result/result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerCtrl;
  static const int _secs = 15;

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _secs),
    );
    final qp = context.read<QuizProvider>();
    if (qp.timed) _startTimer();
  }

  void _startTimer() {
    _timerCtrl.reset();
    _timerCtrl.forward().then((_) {
      if (mounted) _onTimeout();
    });
  }

  void _onTimeout() {
    final qp = context.read<QuizProvider>();
    if (!qp.isAnswered) {
      qp.answerQuestion(-1);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _advance();
      });
    }
  }

  void _onOption(int idx) {
    final qp = context.read<QuizProvider>();
    if (qp.isAnswered) return;
    if (qp.timed) _timerCtrl.stop();
    qp.answerQuestion(idx);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _advance();
    });
  }

  void _advance() {
    final qp = context.read<QuizProvider>();
    if (qp.isLast) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const ResultScreen()));
    } else {
      qp.nextQuestion();
      if (qp.timed) _startTimer();
    }
  }

  @override
  void dispose() { _timerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (ctx, qp, _) {
      if (qp.questions.isEmpty) return const Scaffold(
          backgroundColor: AppTheme.bg,
          body: Center(child: CircularProgressIndicator(color: AppTheme.accent)));

      final color = AppTheme.subjectColors[qp.subject] ?? AppTheme.accent;
      final q = qp.current;

      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _confirmExit(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppTheme.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: qp.progress,
                          backgroundColor: AppTheme.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${qp.currentIndex + 1}/${qp.questions.length}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),

                const SizedBox(height: 16),

                // Timer bar (only in timed mode)
                if (qp.timed)
                  AnimatedBuilder(
                    animation: _timerCtrl,
                    builder: (_, __) {
                      final rem = (_secs * (1 - _timerCtrl.value)).ceil();
                      final urgent = rem <= 5;
                      return Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 1 - _timerCtrl.value,
                                backgroundColor: AppTheme.surfaceLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    urgent ? AppTheme.wrong : color),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: urgent ? 18 : 14,
                              fontWeight: FontWeight.w800,
                              color: urgent ? AppTheme.wrong : AppTheme.textSecondary,
                            ),
                            child: Text('${rem}s'),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 20),

                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question ${qp.currentIndex + 1}',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1)),
                      const SizedBox(height: 10),
                      Text(q.questionText,
                          style: const TextStyle(fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary, height: 1.4)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Options
                ...List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionButton(
                    label: ['A', 'B', 'C', 'D'][i],
                    text: q.options[i],
                    index: i,
                    correctIndex: q.correctIndex,
                    selectedIndex: qp.selectedIndex,
                    isAnswered: qp.isAnswered,
                    color: color,
                    onTap: () => _onOption(i),
                  ),
                )),

                const Spacer(),

                // Explanation
                if (qp.isAnswered && q.explanation.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(q.explanation,
                              style: const TextStyle(fontSize: 13,
                                  color: AppTheme.textSecondary, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Quit Quiz?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Your progress will not be saved.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Continue')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              context.read<QuizProvider>().reset();
            },
            child: const Text('Quit',
                style: TextStyle(color: AppTheme.wrong)),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label, text;
  final int index, correctIndex;
  final int? selectedIndex;
  final bool isAnswered;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label, required this.text, required this.index,
    required this.correctIndex, required this.selectedIndex,
    required this.isAnswered, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppTheme.surfaceLight;
    Color borderColor = AppTheme.border;
    Color textColor = AppTheme.textPrimary;
    Widget? trailing;

    if (isAnswered) {
      if (index == correctIndex) {
        bg = AppTheme.correct.withOpacity(0.12);
        borderColor = AppTheme.correct;
        textColor = AppTheme.correct;
        trailing = const Icon(Icons.check_circle_rounded,
            color: AppTheme.correct, size: 18);
      } else if (index == selectedIndex) {
        bg = AppTheme.wrong.withOpacity(0.12);
        borderColor = AppTheme.wrong;
        textColor = AppTheme.wrong;
        trailing = const Icon(Icons.cancel_rounded,
            color: AppTheme.wrong, size: 18);
      } else {
        bg = AppTheme.surface;
        borderColor = AppTheme.border.withOpacity(0.4);
        textColor = AppTheme.textSecondary.withOpacity(0.4);
      }
    }

    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surface,
                border: Border.all(color: borderColor),
              ),
              child: Center(child: Text(label,
                  style: TextStyle(color: textColor,
                      fontWeight: FontWeight.w700, fontSize: 12))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text,
                style: TextStyle(color: textColor,
                    fontWeight: FontWeight.w500, fontSize: 14))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
