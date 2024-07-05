import 'package:flutter/material.dart';
import 'package:record/pages/home_page.dart';
import 'package:record/themes/dark_theme.dart';
import 'package:record/themes/light_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      // routes: {
      //   '/search': (context) => const SearchPage(),
      // },
    );
  }
}