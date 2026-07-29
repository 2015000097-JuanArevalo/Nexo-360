import 'package:flutter/material.dart';

abstract final class NexoColors {
  static const navy = Color(0xFF020619);
  static const primary = Color(0xFF131954);
  static const royalBlue = Color(0xFF0E6EC7);
  static const cyan = Color(0xFF00A4D6);
  static const violet = Color(0xFF5E109E);
  static const coral = Color(0xFFD4526B);
  static const background = Color(0xFFF4F6FB);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFDDE1ED);

  static const brandGradient = LinearGradient(
    colors: [royalBlue, Color(0xFF191C9F), violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract final class AppTheme {
  static ThemeData light(Color seed) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: NexoColors.background,
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: NexoColors.border),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NexoColors.navy,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: NexoColors.border),
          ),
        ),
      );

  static ThemeData dark(Color seed) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF080B19),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF11162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF2B3150)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NexoColors.navy,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF11162A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
