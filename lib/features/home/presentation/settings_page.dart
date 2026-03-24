import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../auth/presentation/login_page.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  const SettingsPage({super.key, required this.data, required this.isListening});

  @override
  Widget build(BuildContext context) {
    final info = data['systemInfo'] ?? {};
    final bool prox = data['proximityEnabled'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(25, MediaQuery.of(context).padding.top + 10, 25, 20),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening ? Colors.greenAccent : Colors.white10,
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: Align(alignment: Alignment.centerLeft, child: Text("Settings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 30),
            _item('Passive Entry (BLE)', Icons.bluetooth_searching, Colors.blueAccent, Switch(value: prox, activeColor: Colors.blueAccent, onChanged: (v) => http.post(Uri.parse('${AppConfig.baseUrl}/toggle-proximity'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'state': v})))),
            _item("${info['familyMembers'] ?? 1} Members Connected", Icons.people, Colors.blueAccent, null),
            _item("Server IP: ${info['serverIP']}", Icons.lan, Colors.green, null),
            _item("Hardware: ESP32-S3", Icons.memory, Colors.orange, null),
            const SizedBox(height: 40),
            TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), child: const Text("LOG OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _item(String t, IconData i, Color c, Widget? tr) => Card(
    margin: const EdgeInsets.fromLTRB(25, 0, 25, 12), color: const Color(0xFF10141E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ListTile(leading: Icon(i, color: c), title: Text(t, style: const TextStyle(fontSize: 14)), trailing: tr));
}