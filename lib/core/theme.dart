import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent = Color(0xFFFF7A30);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFDFDFD),
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
