import 'package:flutter/material.dart';

abstract final class AppColors {
  // NEXO 360 logo and Colegio Don Bosco inspired palette.
  static const navy = Color(0xFF020619);
  static const primary = Color(0xFF131954);
  static const primaryDark = Color(0xFF080D38);
  static const royalBlue = Color(0xFF0E6EC7);
  static const cyan = Color(0xFF00A4D6);
  static const violet = Color(0xFF5E109E);
  static const youthCoral = Color(0xFFD4526B);
  static const accent = cyan;

  static const background = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const text = Color(0xFF15182B);
  static const muted = Color(0xFF666C8C);
  static const border = Color(0xFFDDE1ED);

  static const success = Color(0xFF168653);
  static const successSurface = Color(0xFFE4F5EC);
  static const pending = Color(0xFFB56A00);
  static const pendingSurface = Color(0xFFFFF1D6);
  static const danger = Color(0xFFC6384B);
  static const dangerSurface = Color(0xFFFCE8EC);

  static const brandGradient = LinearGradient(
    colors: [royalBlue, Color(0xFF191C9F), violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const youthGradient = LinearGradient(
    colors: [youthCoral, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
