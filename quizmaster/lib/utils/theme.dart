import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo);
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );
}
