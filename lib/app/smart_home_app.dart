import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/auth/presentation/login_page.dart';

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // Uses your buildAppTheme from app_theme.dart
      home: const LoginPage(),
    );
  }
}