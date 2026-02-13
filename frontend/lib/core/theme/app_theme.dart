import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const bg = Color(0xFF0B1220);
    const panel = Color(0xFF111A2C);
    const panel2 = Color(0xFF0F1729);
    const stroke = Color(0xFF1F2A44);
    const accent = Color(0xFF4E96E6);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: panel,
      ),
      cardTheme: CardThemeData(
        color: panel2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: stroke, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: Colors.white,
        inactiveTrackColor: stroke,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: stroke),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
