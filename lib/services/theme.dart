import 'package:flutter/material.dart';

    ThemeData lightTheme = ThemeData(
        brightness: Brightness.light,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        colorScheme: ColorScheme.light(
            background: Colors.indigo[500]!,
            primary: Colors.indigo[800]!,
            secondary: Colors.white,
            tertiary: Colors.black12,
            error: Colors.red,
            shadow: Colors.black.withOpacity(0.2),

        )
    );

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    iconTheme: const IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.dark(
      background: Colors.grey[900]!,
      primary: Colors.grey[850]!,
      secondary: Colors.white,
      tertiary: Colors.black12,
      error: Colors.red,
      shadow: Colors.white.withOpacity(0.2),
    )
);