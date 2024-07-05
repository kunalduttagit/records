import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade300,
    inversePrimary: Colors.grey.shade900,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w400, fontSize: 45),
    headlineSmall: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w400, fontSize: 18),
    titleLarge: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w500, fontSize: 14),
    titleMedium: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w400, fontSize: 14),
    titleSmall: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 12),
  )
);