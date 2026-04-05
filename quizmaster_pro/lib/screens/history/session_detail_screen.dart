import 'package:flutter/material.dart';
import '../../models/session.dart';
import '../../models/session_answer.dart';
import '../../database/session_dao.dart';
import '../../utils/theme.dart';

class SessionDetailScreen extends StatefulWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});
  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  List<SessionAnswer> _answers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final answers = await SessionDao.getAnswersForSession(widget.session.id);
    if (mounted) setState(() { _answers = answers; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final color = AppTheme.subjectColors[s.subject] ?? AppTheme.accent;
    final emoji = AppTheme.subjectEmojis[s.subject] ?? '📚';
    final pct = s.percentage;
    final scoreColor = pct >= 70 ? AppTheme.correct
        : pct >= 50 ? AppTheme.warning : AppTheme.wrong;

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
        title: Text(s.subject,
            style: const TextStyle(color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.25), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              _chip(s.difficulty,
                                  s.difficulty == 'easy' ? AppTheme.correct
                                      : s.difficulty == 'medium' ? AppTheme.warning
                                      : AppTheme.wrong),
                              const SizedBox(width: 6),
                              if (s.timed) _chip('⏱ Timed', AppTheme.accent),
                            ]),
                            const SizedBox(height: 6),
                            Text('${s.score}/${s.total} correct',
                                style: TextStyle(fontSize: 20,
                                    fontWeight: FontWeight.w800, color: scoreColor)),
                            Text('${pct.toStringAsFixed(0)}% · ${_fmt(s.completedAt)}',
                                style: const TextStyle(fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Question Breakdown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary, letterSpacing: 0.8)),
                const SizedBox(height: 10),

                ..._answers.asMap().entries.map((e) {
                  final i = e.key;
                  final a = e.value;
                  final q = a.question;
                  if (q == null) return const SizedBox();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: a.isCorrect
                            ? AppTheme.correct.withOpacity(0.3)
                            : AppTheme.wrong.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(
                            a.isCorrect ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: a.isCorrect ? AppTheme.correct : AppTheme.wrong,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text('Q${i + 1}',
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: a.isCorrect ? AppTheme.correct : AppTheme.wrong)),
                          const Spacer(),
                          if (s.timed)
                            Text('${a.timeTakenSecs}s',
                                style: const TextStyle(fontSize: 11,
                                    color: AppTheme.textSecondary)),
                        ]),
                        const SizedBox(height: 6),
                        Text(q.questionText,
                            style: const TextStyle(fontSize: 13,
                                color: AppTheme.textPrimary, height: 1.3)),
                        const SizedBox(height: 8),
                        if (!a.isCorrect) ...[
                          if (a.selectedIndex >= 0)
                            _answerRow('Your answer',
                                q.options[a.selectedIndex], AppTheme.wrong)
                          else
                            _answerRow('Your answer', 'Timed out', AppTheme.warning),
                          const SizedBox(height: 4),
                        ],
                        _answerRow('Correct',
                            q.options[q.correctIndex], AppTheme.correct),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 10, color: color,
        fontWeight: FontWeight.w700)),
  );

  Widget _answerRow(String label, String text, Color color) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label: ', style: TextStyle(fontSize: 11, color: color,
          fontWeight: FontWeight.w700)),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12,
          color: AppTheme.textPrimary))),
    ],
  );
}
