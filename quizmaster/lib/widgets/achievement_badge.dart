import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String hint;
  final bool unlocked;
  final String? unlockedAt;
  final String icon;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.hint,
    required this.unlocked,
    required this.icon,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = unlocked ? 1.0 : 0.35;
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x0E000000))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              unlocked ? (unlockedAt ?? 'Unlocked') : hint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
