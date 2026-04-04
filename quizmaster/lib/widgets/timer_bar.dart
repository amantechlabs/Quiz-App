import 'package:flutter/material.dart';

class TimerBar extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  const TimerBar({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : secondsLeft / totalSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time left: $secondsLeft s', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
