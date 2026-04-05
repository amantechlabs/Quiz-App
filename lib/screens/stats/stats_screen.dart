import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/session_dao.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, double> _subjectAcc = {};
  Map<String, double> _diffAcc = {};
  Map<String, dynamic> _overall = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = context.read<ProfileProvider>().active?.id;
    if (id == null) return;
    final sub = await SessionDao.getSubjectAccuracy(id);
    final diff = await SessionDao.getDifficultyAccuracy(id);
    final overall = await SessionDao.getOverallStats(id);
    if (mounted) setState(() {
      _subjectAcc = sub;
      _diffAcc = diff;
      _overall = overall;
      _loading = false;
    });
  }

  static const List<String> _subjects = [
    'Geography', 'History', 'Political Science', 'Physics',
    'Biology', 'Chemistry', 'Mathematics', 'General Knowledge',
    'General Science',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  const Text('Statistics',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 20),

                  // Overall stats grid
                  _sectionLabel('Overview'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _overallCard('🎮 Quizzes',
                          '${_overall['total_sessions'] ?? 0}', AppTheme.accent),
                      _overallCard('❓ Questions',
                          '${_overall['total_questions'] ?? 0}', AppTheme.warning),
                      _overallCard('✅ Correct',
                          '${_overall['total_correct'] ?? 0}', AppTheme.correct),
                      _overallCard('🏆 Best Score',
                          '${(_overall['best_score'] as double? ?? 0).toStringAsFixed(0)}%',
                          AppTheme.wrong),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Difficulty breakdown
                  _sectionLabel('Accuracy by Difficulty'),
                  const SizedBox(height: 10),
                  Row(children: [
                    _diffCard('Easy', _diffAcc['easy'] ?? 0, AppTheme.correct),
                    const SizedBox(width: 10),
                    _diffCard('Medium', _diffAcc['medium'] ?? 0, AppTheme.warning),
                    const SizedBox(width: 10),
                    _diffCard('Hard', _diffAcc['hard'] ?? 0, AppTheme.wrong),
                  ]),

                  const SizedBox(height: 24),

                  // Subject accuracy bars
                  _sectionLabel('Accuracy by Subject'),
                  const SizedBox(height: 12),
                  ..._subjects.map((subj) {
                    final acc = _subjectAcc[subj];
                    final color = AppTheme.subjectColors[subj] ?? AppTheme.accent;
                    final emoji = AppTheme.subjectEmojis[subj] ?? '📚';
                    return _SubjectBar(
                      subject: subj,
                      emoji: emoji,
                      accuracy: acc,
                      color: color,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary, letterSpacing: 0.8));

  Widget _overallCard(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 12,
            color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.w800, color: color)),
      ],
    ),
  );

  Widget _diffCard(String label, double acc, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text('${acc.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11,
            color: AppTheme.textSecondary)),
      ]),
    ),
  );
}

class _SubjectBar extends StatelessWidget {
  final String subject, emoji;
  final double? accuracy;
  final Color color;
  const _SubjectBar({required this.subject, required this.emoji,
      required this.accuracy, required this.color});

  @override
  Widget build(BuildContext context) {
    final played = accuracy != null;
    final pct = accuracy ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(child: Text(subject,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
            Text(played ? '${pct.toStringAsFixed(0)}%' : 'Not played',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: played ? color : AppTheme.textSecondary)),
          ]),
          if (played) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
