import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/achievement_dao.dart';
import '../../models/achievement.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = context.read<ProfileProvider>().active?.id;
    if (id == null) return;
    final list = await AchievementDao.getAllForProfile(id);
    if (mounted) setState(() { _achievements = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    final total = _achievements.length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Achievements',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                Text('$unlocked/$total',
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : unlocked / total,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 6,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(
                    color: AppTheme.accent))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _achievements.length,
                    itemBuilder: (_, i) => _AchievementTile(
                        achievement: _achievements[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.warning.withOpacity(0.07)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? AppTheme.warning.withOpacity(0.35)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          // Badge
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppTheme.warning.withOpacity(0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked
                    ? AppTheme.warning.withOpacity(0.4)
                    : AppTheme.border,
              ),
            ),
            child: Center(
              child: unlocked
                  ? Text(achievement.emoji,
                      style: const TextStyle(fontSize: 26))
                  : const Icon(Icons.lock_rounded,
                      color: AppTheme.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: unlocked
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    )),
                const SizedBox(height: 3),
                Text(
                  unlocked
                      ? achievement.description
                      : achievement.unlockHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary.withOpacity(0.5),
                    height: 1.3,
                  ),
                ),
                if (unlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Unlocked ${_fmtDate(achievement.unlockedAt!)}',
                      style: const TextStyle(fontSize: 11,
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.star_rounded,
                color: AppTheme.warning, size: 20),
        ],
      ),
    );
  }
}
