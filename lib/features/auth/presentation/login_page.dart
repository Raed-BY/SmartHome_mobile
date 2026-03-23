import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/core/widgets/app_logo.dart';
import 'package:mobile_app/features/auth/presentation/signup_page.dart';
import 'package:mobile_app/features/home/presentation/main_container.dart';

// Login screen for existing users.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form controllers.
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  // Sends credentials to backend and routes user on success.
  Future<void> _login() async {
    try {
      // POST /login with JSON payload.
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email.text, 'pass': _pass.text}),
      );

      // Prevents using context if widget was disposed.
      if (!mounted) {
        return;
      }

      // 201 means authentication succeeded.
      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
        );
      } else {
        // User feedback for invalid credentials.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      // User feedback for offline backend/network issue.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server Offline')),
      );
    }
  }

  @override
  void dispose() {
    // Releases controller resources.
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Prevents overflow on small screens.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const AppLogo(),
              const SizedBox(height: 50),
              // Email input.
              _input('Email', Icons.email_outlined, _email),
              const SizedBox(height: 20),
              // Password input.
              _input('Password', Icons.lock_outline, _pass, obscure: true),
              const SizedBox(height: 40),
              // Submit login action.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _login,
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Navigate to registration page.
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white24),
                ),
              ),
            ],
          ),
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
