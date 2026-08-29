import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF090B10);
  static const card = Color(0xFF141720);
  static const cardBorder = Color(0xFF292E39);
  static const pink = Color(0xFFFF3E9D);
  static const pinkSoft = Color(0xFFFF82BE);
  static const textSecondary = Color(0xFFA8AFBC);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: pink,
        secondary: pinkSoft,
        surface: card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
