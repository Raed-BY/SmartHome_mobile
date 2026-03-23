import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/app_config.dart';

// Registration screen for new users.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Form controllers.
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  // Sends signup data to backend, then returns to login page.
  Future<void> _register() async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _name.text,
          'email': _email.text,
          'pass': _pass.text,
        }),
      );

      if (!mounted) {
        return;
      }
      // Back to previous page after successful account creation.
      Navigator.pop(context);
    } catch (_) {}
  }

  @override
  void dispose() {
    // Releases controller resources.
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text(
              'Join SmartHome',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Name input.
            _input('Full Name', Icons.person, _name),
            const SizedBox(height: 20),
            // Email input.
            _input('Email', Icons.email, _email),
            const SizedBox(height: 20),
            // Password input.
            _input('Password', Icons.lock, _pass, obscure: true),
            const SizedBox(height: 40),
            // Submit registration action.
            ElevatedButton(
                onPressed: _register, child: const Text('CREATE ACCOUNT')),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    // Shared styled input field.
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF10141E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
