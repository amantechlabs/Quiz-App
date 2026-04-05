import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color bg = Color(0xFF0D0D14);
  static const Color surface = Color(0xFF16161F);
  static const Color surfaceLight = Color(0xFF1E1E2A);
  static const Color border = Color(0xFF2A2A3A);
  static const Color accent = Color(0xFF7C6FF7);
  static const Color accentLight = Color(0xFF9D96FF);
  static const Color correct = Color(0xFF22C55E);
  static const Color wrong = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFEEEEF5);
  static const Color textSecondary = Color(0xFF8888A8);

  // Subject colours
  static const Map<String, Color> subjectColors = {
    'Geography':       Color(0xFF06B6D4),
    'History':         Color(0xFFF59E0B),
    'Political Science': Color(0xFF8B5CF6),
    'Physics':         Color(0xFF3B82F6),
    'Biology':         Color(0xFF22C55E),
    'Chemistry':       Color(0xFFEC4899),
    'Mathematics':     Color(0xFFF97316),
    'General Knowledge': Color(0xFF14B8A6),
    'General Science': Color(0xFF6366F1),
  };

  static const Map<String, String> subjectEmojis = {
    'Geography':       '🌍',
    'History':         '📜',
    'Political Science': '🏛️',
    'Physics':         '⚛️',
    'Biology':         '🧬',
    'Chemistry':       '🧪',
    'Mathematics':     '📐',
    'General Knowledge': '💡',
    'General Science': '🔬',
  };

  static const List<String> avatarOptions = [
    '🦁','🐯','🦊','🐺','🦝','🐻','🐼','🐨','🐸','🦋',
    '🦄','🐉','🦅','🦉','🦚','🐬','🦈','🌟','🔥','⚡',
    '🎯','🏆','💎','🚀','🎭','🎓','👾','🤖','🧠','💫',
  ];

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        background: bg,
        surface: surface,
        primary: accent,
        onPrimary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}

class AppConstants {
  static const List<int> questionCounts = [5, 10, 15];
  static const List<String> difficulties = ['easy', 'medium', 'hard'];
  static const int timerSeconds = 15;
  static const int maxHistorySessions = 15;
}
