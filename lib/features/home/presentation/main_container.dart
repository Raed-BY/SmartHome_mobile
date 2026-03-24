import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/config/app_config.dart';
import 'control_page.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _index = 0;
  bool _isSystemAwake = false; 
  Map<String, dynamic> data = {
    'tempSalon': 0, 'soilMoisture': 0, 'manualPump': false, 'manualCanopy': false,
    'garageOpen': false, 'proximityEnabled': true,
    'lights': {'Living Room': false, 'Bedroom': false, 'Kitchen': false, 'Garage': false},
    'systemInfo': {'userName': 'User', 'familyMembers': 1}
  };

  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (t) => _fetchData());
  }

  void _startAssistant() async {
    bool avail = await _speech.initialize(onStatus: (s) {
      if (s == 'done' || s == 'notListening') if (_isSystemAwake) _listenLoop();
    });
    if (avail) _listenLoop();
  }

  void _listenLoop() {
    _speech.listen(onResult: (val) => _processVoice(val.recognizedWords.toLowerCase()));
    if (mounted) setState(() {});
  }

  void _processVoice(String cmd) {
    if (cmd.contains("bedroom") && cmd.contains("on")) _toggle('toggle-light', {'name': 'Bedroom', 'state': true});
    if (cmd.contains("bedroom") && cmd.contains("off")) _toggle('toggle-light', {'name': 'Bedroom', 'state': false});
    if (cmd.contains("open") && cmd.contains("garage")) _toggle('toggle-garage', {'state': true});
    if (cmd.contains("close") && cmd.contains("garage")) _toggle('toggle-garage', {'state': false});
    if (cmd.contains("water") || cmd.contains("pump")) _toggle('toggle-pump', {'state': cmd.contains("on")});
    if (cmd.contains("canopy")) _toggle('toggle-canopy', {'state': cmd.contains("on")});
  }

  Future<void> _toggle(String path, dynamic body) async {
    try { await http.post(Uri.parse('${AppConfig.baseUrl}/$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)); } catch (_) {}
  }

  Future<void> _fetchData() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/status'));
      if (res.statusCode == 200 && mounted) setState(() => data = jsonDecode(res.body));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSystemAwake) {
      return GestureDetector(
        onTap: () { setState(() => _isSystemAwake = true); _startAssistant(); },
        child: Scaffold(body: Center(child: Icon(Icons.bolt_rounded, size: 100, color: Colors.blueAccent.withOpacity(0.3)))),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: [
        DashboardPage(data: data, isListening: _speech.isListening),
        ControlPage(data: data, isListening: _speech.isListening),
        SettingsPage(data: data, isListening: _speech.isListening),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, onTap: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF02040A), selectedItemColor: Colors.blueAccent, unselectedItemColor: Colors.white10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}