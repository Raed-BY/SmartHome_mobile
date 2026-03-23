import 'package:flutter/material.dart';

// Global visual style used by MaterialApp.
ThemeData buildAppTheme() {
  return ThemeData(
    // Dark UI baseline.
    brightness: Brightness.dark,
    // Main background color for screens.
    scaffoldBackgroundColor: const Color(0xFF02040A),
    // Default app font.
    fontFamily: 'Segoe UI',
  );
}
