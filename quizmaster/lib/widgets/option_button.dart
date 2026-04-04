import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final bool correct;
  final bool reveal;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color fg = Colors.black87;

    if (reveal) {
      if (correct) {
        bg = Colors.green.shade50;
        border = Colors.green;
        fg = Colors.green.shade900;
      } else if (selected) {
        bg = Colors.red.shade50;
        border = Colors.red;
        fg = Colors.red.shade900;
      }
    } else if (selected) {
      bg = Theme.of(context).colorScheme.primaryContainer;
      border = Theme.of(context).colorScheme.primary;
      fg = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Text(text, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
