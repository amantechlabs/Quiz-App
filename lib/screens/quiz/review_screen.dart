import 'package:flutter/material.dart';
import '../../models/session_answer.dart';
import '../../utils/theme.dart';

class ReviewScreen extends StatelessWidget {
  final List<SessionAnswer> answers;
  const ReviewScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    final wrong = answers.where((a) => !a.isCorrect).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 18),
        ),
        title: const Text('Review Wrong Answers',
            style: TextStyle(color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700)),
      ),
      body: wrong.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 12),
                  Text('Perfect score!\nNo wrong answers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18,
                          color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wrong.length,
              itemBuilder: (_, i) {
                final a = wrong[i];
                final q = a.question;
                if (q == null) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q${i + 1}',
                          style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(q.questionText,
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary, height: 1.4)),
                      const SizedBox(height: 12),

                      // User's wrong answer
                      if (a.selectedIndex >= 0)
                        _AnswerRow(
                          label: 'Your answer',
                          text: q.options[a.selectedIndex],
                          color: AppTheme.wrong,
                          icon: Icons.cancel_rounded,
                        )
                      else
                        _AnswerRow(
                          label: 'Your answer',
                          text: 'Time ran out',
                          color: AppTheme.warning,
                          icon: Icons.timer_off_rounded,
                        ),

                      const SizedBox(height: 6),
                      _AnswerRow(
                        label: 'Correct answer',
                        text: q.options[q.correctIndex],
                        color: AppTheme.correct,
                        icon: Icons.check_circle_rounded,
                      ),

                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(q.explanation,
                                    style: const TextStyle(fontSize: 12,
                                        color: AppTheme.textSecondary,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label, text;
  final Color color;
  final IconData icon;
  const _AnswerRow({required this.label, required this.text,
      required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$label: ',
                    style: TextStyle(fontSize: 12, color: color,
                        fontWeight: FontWeight.w600)),
                TextSpan(text: text,
                    style: const TextStyle(fontSize: 13,
                        color: AppTheme.textPrimary, height: 1.3)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
