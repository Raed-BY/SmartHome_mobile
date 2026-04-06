import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../auth/presentation/login_page.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  const SettingsPage(
      {super.key, required this.data, required this.isListening});

  // --- 🔐 PROFESSIONAL PASSWORD DIALOG WITH LIVE VALIDATION 🔐 ---
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passController = TextEditingController();
    String? errorText; // Holds the red error message

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D1117), // Deep midnight grey
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            title: Column(
              children: [
                // Centered Icon at the top
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Colors.orangeAccent, size: 30),
                ),
                const SizedBox(height: 15),
                const Text("Security Update",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose a strong password to protect your home system.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    // Remove red error text as soon as user starts typing
                    if (errorText != null) {
                      setDialogState(() => errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "New Password",
                    hintStyle: const TextStyle(color: Colors.white24),
                    prefixIcon:
                        const Icon(Icons.key_rounded, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    // --- ERROR LOGIC ---
                    errorText: errorText,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL",
                          style: TextStyle(
                              color: Colors.white38,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        // --- 🛑 VALIDATION CHECK 🛑 ---
                        if (passController.text.length < 6) {
                          setDialogState(() {
                            errorText = "Must be 6 characters minimum";
                          });
                        } else {
                          // Success: Talk to NestJS Backend
                          try {
                            await http.post(
                              Uri.parse('${AppConfig.baseUrl}/change-password'),
                              headers: {'Content-Type': 'application/json'},
                              body:
                                  jsonEncode({'newPass': passController.text}),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Password successfully updated!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("Update failed: $e");
                          }
                        }
                      },
                      child: const Text("UPDATE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = data['systemInfo'] ?? {};
    final bool prox = data['proximityEnabled'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: VOICE INDICATOR ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                  25, MediaQuery.of(context).padding.top + 10, 25, 20),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isListening ? Colors.greenAccent : Colors.white10,
                        boxShadow: isListening
                            ? [
                                BoxShadow(
                                    color: Colors.greenAccent
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8)
                              ]
                            : [],
                      ))),
            ),

            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text("Settings",
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),

            // --- 1. PASSIVE ENTRY SECTION ---
            _item(
              'Passive Entry (BLE)',
              'Unlock garage via proximity',
              Icons.bluetooth_searching,
              Colors.blueAccent,
              Switch(
                value: prox,
                activeThumbColor: Colors.blueAccent,
                onChanged: (v) => http.post(
                    Uri.parse('${AppConfig.baseUrl}/toggle-proximity'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'state': v})),
              ),
            ),

            // --- 2. SECURITY SECTION ---
            _item(
              'System Password',
              'Change your access key',
              Icons.shield_moon_outlined,
              Colors.orangeAccent,
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white24),
                onPressed: () => _showPasswordDialog(context),
              ),
            ),

            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("System Information",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white38,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // --- 3. HARDWARE & FAMILY INFO ---
            _item(
                "${info['activeMembers'] ?? 1} Members Connected",
                'Real-time active app connections',
                Icons.people_outline,
                Colors.blueAccent,
                null),
            _item(
                "${info['familyMembers'] ?? 1} Registered Members",
                'Accounts saved in system',
                Icons.groups_2_outlined,
                Colors.indigoAccent,
                null),
            _item("Server IP: ${info['serverIP']}", 'Backend communication',
                Icons.lan, Colors.green, null),
            _item("Hardware: ESP32-S3", 'System controller', Icons.memory,
                Colors.purpleAccent, null),

            const SizedBox(height: 50),

            // --- LOGOUT ---
            Center(
              child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage())),
                  child: const Text("DISCONNECT FROM SYSTEM",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5))),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE SETTINGS ITEM COMPONENT ---
  Widget _item(String title, String subtitle, IconData icon, Color color,
      Widget? trailing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white24)),
        trailing: trailing,
      ),
    );
  }
}
