import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session.dart';
import '../../models/achievement.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../database/achievement_dao.dart';
import '../../utils/achievement_engine.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;
  Session? _session;
  List<String> _newAchievements = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1, curve: Curves.elasticOut));
    _ctrl.forward();
    _saveSession();
  }

  Future<void> _saveSession() async {
    final qp = context.read<QuizProvider>();
    final profileId = context.read<ProfileProvider>().active!.id;
    final session = await qp.saveSession();
    final newA = await AchievementEngine.evaluate(
      profileId: profileId,
      session: session,
      answers: qp.answers.toList(),
    );
    await context.read<HistoryProvider>().load(profileId);
    if (mounted) setState(() { _session = session; _newAchievements = newA; _saved = true; });
  }

  Color _scoreColor(double pct) {
    if (pct >= 70) return AppTheme.correct;
    if (pct >= 50) return AppTheme.warning;
    return AppTheme.wrong;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QuizProvider>();
    final total = qp.questions.length;
    final score = qp.score;
    final pct = total == 0 ? 0.0 : score / total * 100;
    final color = _scoreColor(pct);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Score circle
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                      gradient: RadialGradient(colors: [
                        color.withOpacity(0.2), Colors.transparent]),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$score',
                            style: TextStyle(fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: color, height: 1)),
                        Text('out of $total',
                            style: const TextStyle(fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(_session?.grade ?? '…',
                    style: const TextStyle(fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text('${qp.subject} · ${qp.difficulty.toUpperCase()}',
                    style: const TextStyle(fontSize: 13,
                        color: AppTheme.textSecondary)),

                const SizedBox(height: 28),

                // Stats row
                Row(
                  children: [
                    _stat('✅ Correct', '$score', AppTheme.correct),
                    const SizedBox(width: 10),
                    _stat('❌ Wrong', '${total - score}', AppTheme.wrong),
                    const SizedBox(width: 10),
                    _stat('📊 Score',
                        '${pct.toStringAsFixed(0)}%', AppTheme.accent),
                  ],
                ),

                // New achievements
                if (_newAchievements.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🏆 New Achievement!',
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.warning)),
                        const SizedBox(height: 8),
                        ..._newAchievements.map((id) {
                          final a = Achievement.all
                              .firstWhere((x) => x.id == id,
                              orElse: () => Achievement(
                                id: id, title: id, emoji: '🏅',
                                description: '', unlockHint: ''));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(children: [
                              Text(a.emoji,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(a.title,
                                  style: const TextStyle(fontSize: 14,
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => ReviewScreen(answers: qp.answers.toList()))),
                    icon: const Icon(Icons.reviews_rounded, size: 18),
                    label: const Text('Review Answers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      qp.reset();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false);
                    },
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 10,
              color: AppTheme.textSecondary)),
        ],
      ),
    ),
  );
}
