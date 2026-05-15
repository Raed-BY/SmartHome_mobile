import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/core/widgets/app_logo.dart';
import 'package:mobile_app/core/services/biometric_service.dart';
import 'package:mobile_app/core/services/secure_storage_service.dart';
// Signup is managed externally; no in-app registration.
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
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter email and password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final reachable = await AppConfig.ensureReachable();
      if (!reachable) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend not reachable. Check Wi-Fi and firewall.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // POST /login with JSON payload.
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'pass': pass}),
          )
          .timeout(const Duration(seconds: 6));

      // Prevents using context if widget was disposed.
      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        if (token != null) {
          await SecureStorageService.saveToken(token);
        }
        // Also save credentials locally so fingerprint can unlock without typing.
        await SecureStorageService.saveCredentials(email, pass);
        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed (${response.statusCode})'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on SocketException catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Server Offline. Check Wi-Fi and server IP: ${AppConfig.baseUrl}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } on TimeoutException catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server timeout. Try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } on http.ClientException catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Network error. Verify backend URL: ${AppConfig.baseUrl}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed due to unexpected error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _loginWithStoredCredentials() async {
    final creds = await SecureStorageService.readCredentials();
    final email = creds['email'] ?? '';
    final pass = creds['pass'] ?? '';
    if (email.isEmpty || pass.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No stored credentials. Sign in once to enable fingerprint.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Populate fields and attempt normal login flow.
    _email.text = email;
    _pass.text = pass;
    await _login();
  }

  @override
  void dispose() {
    // Releases controller resources.
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // Biometric helper
  final BiometricService _biometric = BiometricService();
  bool _biometricAvailable = false;
  bool _isBiometricBusy = false;

  @override
  void initState() {
    super.initState();
    _initBiometricAutoLogin();
  }

  Future<void> _initBiometricAutoLogin() async {
    // Check if device supports biometrics and whether we have stored creds.
    final creds = await SecureStorageService.readCredentials();
    final hasCreds = (creds['email']?.isNotEmpty ?? false) &&
        (creds['pass']?.isNotEmpty ?? false);
    final bioOk = await _biometric.canCheckBiometrics();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = bioOk;
    });

    // If biometrics available and credentials stored, attempt immediate auth and auto-login.
    if (bioOk && hasCreds) {
      await _tryBiometricLogin(showFailureMessage: false);
    }
  }

  Future<void> _tryBiometricLogin({bool showFailureMessage = true}) async {
    if (_isBiometricBusy) {
      return;
    }

    setState(() => _isBiometricBusy = true);
    try {
      final ok = await _biometric.authenticate(
        localizedReason: 'Authenticate to sign in',
      );

      if (ok) {
        await _loginWithStoredCredentials();
      } else if (showFailureMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Fingerprint authentication was cancelled or failed.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBiometricBusy = false);
      }
    }
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
              const SizedBox(height: 12),
              if (_biometricAvailable)
                OutlinedButton.icon(
                  onPressed: _isBiometricBusy
                      ? null
                      : () => _tryBiometricLogin(showFailureMessage: true),
                  icon: const Icon(Icons.fingerprint),
                  label: Text(_isBiometricBusy
                      ? 'AUTHENTICATING...'
                      : 'SIGN IN WITH FINGERPRINT'),
                ),
              const SizedBox(height: 20),
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
