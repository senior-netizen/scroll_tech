import 'package:flutter/material.dart';

import '../presentation/splash/splash_screen.dart';

class ScrollTechApp extends StatelessWidget {
  const ScrollTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Tech',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
