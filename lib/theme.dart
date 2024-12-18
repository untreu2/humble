import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFFBF1C7),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF458588),
      secondary: Color(0xFFB16286),
      surface: Color(0xFFFBF1C7),
      error: Color(0xFFCC241D),
      onPrimary: Color(0xFFFBF1C7),
      onSecondary: Color(0xFFFBF1C7),
      onSurface: Color(0xFF282828),
      onError: Color(0xFFFBF1C7),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF458588),
        foregroundColor: const Color(0xFFFBF1C7),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.white,
      surface: Colors.black,
      error: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    ),
  );
}
