import 'package:flutter/material.dart';

import 'features/auth/presentation/auth_page.dart';

class ScrollTechApp extends StatelessWidget {
  const ScrollTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Tech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthPage(),
    );
  }
}
