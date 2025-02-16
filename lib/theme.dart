import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFD5C4A1),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF665C54),
      secondary: Color(0xFF928374),
      surface: Color(0xFFD5C4A1),
      error: Color(0xFFCC241D),
      onPrimary: Color(0xFFFBF1C7),
      onSecondary: Color(0xFF3C3836),
      onSurface: Color(0xFF3C3836),
      onError: Color(0xFFFBF1C7),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF665C54),
        foregroundColor: const Color(0xFFFBF1C7),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1D2021),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBDAE93),
      secondary: Color(0xFF665C54),
      surface: Color(0xFF1D2021),
      error: Color(0xFFFB4934),
      onPrimary: Color(0xFF1D2021),
      onSecondary: Color(0xFFD5C4A1),
      onSurface: Color(0xFFD5C4A1),
      onError: Color(0xFF1D2021),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF665C54),
        foregroundColor: const Color(0xFF3C3836),
      ),
    ),
  );
}
