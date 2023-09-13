import 'package:flutter/material.dart';

    ThemeData lightTheme = ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
            background: Colors.white,
            primary: Colors.indigo[700]!,
            secondary: Colors.white,
            tertiary: Colors.black12,
            error: Colors.red,
            shadow: Colors.black.withOpacity(0.2),
        )
    );

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.black,
      primary: Colors.indigo[700]!,
      secondary: Colors.white,
      tertiary: Colors.black12,
      error: Colors.red,
      shadow: Colors.black.withOpacity(0.2),
    )
);
