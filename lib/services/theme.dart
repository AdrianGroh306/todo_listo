import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    iconTheme: IconThemeData(
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
      error: Colors.red,
      shadow: Colors.black,
      scrim: Colors.transparent,
    ));

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    iconTheme: IconThemeData(color: Colors.white),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionHandleColor:
          Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      surface: Colors.grey[900]!,
      primary: Colors.grey[850]!,
      secondary: Colors.white,
      tertiary: Colors.black12,
      error: Colors.red,
      shadow: Colors.white,
      scrim: Colors.transparent,
    ));
