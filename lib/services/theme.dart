import 'package:flutter/material.dart';

    ThemeData lightTheme = ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
            background: Colors.white,
            primary: Colors.indigo,
            secondary: Colors.white,
            tertiary: Colors.black12,
            error: Colors.red,
            shadow: Colors.black,//.withOpacity(0.2),

        )
    );

    ThemeData darkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
            background: Colors.black,
            primary: Colors.indigo,
            secondary: Colors.blue,
        )
    );
