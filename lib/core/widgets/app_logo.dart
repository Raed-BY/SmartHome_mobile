import 'package:flutter/material.dart';

// Reusable logo widget shown on auth pages.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular badge containing the bolt icon.
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10141E),
            boxShadow: [
              // Soft blue glow around the badge.
              BoxShadow(
                color: Colors.blueAccent.withValues(alpha: 0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, size: 70, color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 20),
        // Brand name text under the icon.
        const Text(
          'SmartHome',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
