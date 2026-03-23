import 'package:flutter/material.dart';
import 'package:mobile_app/app/app_theme.dart';
import 'package:mobile_app/features/auth/presentation/login_page.dart';

// Root app widget: theme + first route.
class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides debug banner in top-right corner.
      debugShowCheckedModeBanner: false,
      // Uses centralized app theme.
      theme: buildAppTheme(),
      // First screen shown to user.
      home: const LoginPage(),
    );
  }
}
