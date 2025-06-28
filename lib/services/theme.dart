import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionHandleColor: Colors.white,
  ),
  colorScheme: ColorScheme.light(
    surface: Colors.indigo[500]!,
    primary: Colors.indigo[800]!,
    secondary: Colors.white,
    tertiary: Colors.black12,
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.indigo[800]!,
    surfaceVariant: Colors.indigo[400]!,
    outline: Colors.indigo[300]!,
    error: Colors.red,
    shadow: Colors.black,
    scrim: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: const CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionHandleColor: Colors.white,
  ),
  colorScheme: ColorScheme.dark(
    surface: Colors.grey[900]!,
    primary: Colors.grey[850]!,
    secondary: Colors.white,
    tertiary: Colors.black12,
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.grey[850]!,
    surfaceVariant: Colors.grey[800]!,
    outline: Colors.grey[600]!,
    error: Colors.red,
    shadow: Colors.white,
    scrim: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: const CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 2),
    ),
  ),
);
