import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/session.dart';
import '../../database/session_dao.dart';
import '../../utils/theme.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final id = context.read<ProfileProvider>().active?.id;
    if (id != null) context.read<HistoryProvider>().load(id);
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HistoryProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('History',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
          ),
          Expanded(
            child: hp.loading
                ? const Center(child: CircularProgressIndicator(
                    color: AppTheme.accent))
                : hp.sessions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📋', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text('No sessions yet.\nStart a quiz!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: hp.sessions.length,
                        itemBuilder: (_, i) {
                          final s = hp.sessions[i];
                          return _SessionTile(
                            session: s,
                            dateStr: _formatDate(s.completedAt),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    SessionDetailScreen(session: s))),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final String dateStr;
  final VoidCallback onTap;
  const _SessionTile({required this.session, required this.dateStr,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColors[session.subject] ?? AppTheme.accent;
    final emoji = AppTheme.subjectEmojis[session.subject] ?? '📚';
    final pct = session.percentage;
    final scoreColor = pct >= 70
        ? AppTheme.correct
        : pct >= 50
            ? AppTheme.warning
            : AppTheme.wrong;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.subject,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _tag(session.difficulty,
                          session.difficulty == 'easy'
                              ? AppTheme.correct
                              : session.difficulty == 'medium'
                                  ? AppTheme.warning
                                  : AppTheme.wrong),
                      const SizedBox(width: 6),
                      if (session.timed) _tag('⏱ Timed', AppTheme.accent),
                      const Spacer(),
                      Text(dateStr,
                          style: const TextStyle(fontSize: 11,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session.score}/${session.total}',
                    style: TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w800, color: scoreColor)),
                Text('${pct.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 11,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: TextStyle(fontSize: 10,
        color: color, fontWeight: FontWeight.w600)),
  );
}
