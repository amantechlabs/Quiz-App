import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String emoji;
  final int questionCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primaryContainer, Colors.white],
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 20, offset: Offset(0, 10), color: Color(0x11000000)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('$questionCount questions', style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
