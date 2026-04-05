import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/theme.dart';
import 'quiz_screen.dart';

class QuizConfigScreen extends StatefulWidget {
  final String subject;
  const QuizConfigScreen({super.key, required this.subject});
  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String _difficulty = 'easy';
  int _count = 10;
  bool _timed = true;

  final _difficulties = ['easy', 'medium', 'hard'];
  final _counts = [5, 10, 15];
  final _diffLabels = {'easy': 'Easy 😊', 'medium': 'Medium 🤔', 'hard': 'Hard 🔥'};
  final _diffColors = {
    'easy': AppTheme.correct,
    'medium': AppTheme.warning,
    'hard': AppTheme.wrong,
  };

  Future<void> _start() async {
    final profile = context.read<ProfileProvider>().active!;
    final qp = context.read<QuizProvider>();
    await qp.startQuiz(
      subject: widget.subject,
      difficulty: _difficulty,
      questionCount: _count,
      timed: _timed,
      profileId: profile.id,
    );
    if (!mounted) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const QuizScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColors[widget.subject] ?? AppTheme.accent;
    final emoji = AppTheme.subjectEmojis[widget.subject] ?? '📚';

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
        title: const Text('Quiz Setup',
            style: TextStyle(color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.subject,
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      Text('500 questions available',
                          style: TextStyle(fontSize: 13,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Difficulty
            _label('Difficulty'),
            const SizedBox(height: 10),
            Row(
              children: _difficulties.map((d) {
                final sel = d == _difficulty;
                final c = _diffColors[d]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? c.withOpacity(0.15) : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? c : AppTheme.border,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Center(
                        child: Text(_diffLabels[d]!,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: sel ? c : AppTheme.textSecondary)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Question count
            _label('Number of Questions'),
            const SizedBox(height: 10),
            Row(
              children: _counts.map((c) {
                final sel = c == _count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _count = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.accent.withOpacity(0.15)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? AppTheme.accent : AppTheme.border,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Center(
                        child: Text('$c',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: sel
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Timer toggle
            _label('Timer Mode'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('15 seconds per question',
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        Text(_timed ? 'Timer ON' : 'Timer OFF',
                            style: TextStyle(fontSize: 12,
                                color: _timed
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _timed,
                    onChanged: (v) => setState(() => _timed = v),
                    activeColor: AppTheme.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text('Start Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary, letterSpacing: 0.8));
}
