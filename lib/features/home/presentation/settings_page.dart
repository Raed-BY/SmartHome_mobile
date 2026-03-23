import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/presentation/login_page.dart';

// User/system settings overview page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.data});

  // Shared status payload from backend.
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    // Safe fallback if systemInfo is missing.
    final Map<String, dynamic> info = data['systemInfo'] ?? <String, dynamic>{};

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          25, MediaQuery.of(context).padding.top + 40, 25, 20),
      child: Column(
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 35),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person),
            ),
            title: Text(info['userName'] ?? 'User'),
            subtitle: const Text('Master Access'),
          ),
          const SizedBox(height: 35),
          // Information tiles read from backend payload.
          _tile(
              'Server IP', info['serverIP'] ?? '...', Icons.lan, Colors.green),
          _tile('Device', info['deviceModel'] ?? '...', Icons.memory,
              Colors.orange),
          _tile('WiFi', info['wifiStatus'] ?? '...', Icons.wifi, Colors.blue),
          const SizedBox(height: 50),
          // Logout returns to login page.
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            child: const Text(
              'LOG OUT',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable settings info tile.
  Widget _tile(String title, String subtitle, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF10141E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white24),
        ),
      ),
    );
  }
}
