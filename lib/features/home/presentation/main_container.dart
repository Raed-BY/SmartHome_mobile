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
  bool _isServerOnline = true;
  bool _isAwaitingCommand = false;
  bool _voiceAssistantAvailable = true;
  Timer? _commandWindowTimer;
  Timer? _pollTimer;
  final String _clientId =
      '${DateTime.now().millisecondsSinceEpoch}-${identityHashCode(Object())}';
  Map<String, dynamic> data = {
    'tempSalon': 0,
    'soilMoisture': 0,
    'gasLevel': 0,
    'isRaining': false,
    'manualPump': false,
    'manualCanopy': false,
    'garageOpen': false,
    'lastVisitor': 'No one at the door',
    'lights': {
      'Living Room': false,
      'Bedroom': false,
      'Kitchen': false,
      'Garage': false
    },
    'systemInfo': {'userName': 'User', 'activeMembers': 1, 'familyMembers': 1}
  };

  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 2), (t) => _fetchData());
  }

  // --- 1. ACTION & ALERT LOGIC ---
  Future<void> _toggle(String path, dynamic body) async {
    try {
      await http.post(Uri.parse('${AppConfig.baseUrl}/$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
    } catch (_) {}
  }

  void _sendAlert(String title, String body) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title: $body')),
      );
    }
  }

  void _checkForAutomations(Map<String, dynamic> newData) {
    if (newData['gasLevel'] > 450 && data['gasLevel'] <= 450) {
      _sendAlert("⚠️ GAS EMERGENCY", "Dangerous gas levels detected!");
    }
    if (newData['soilMoisture'] < 30 &&
        data['soilMoisture'] >= 30 &&
        newData['manualPump'] == false) {
      _sendAlert("💧 Irrigation", "Garden pump started automatically.");
    }
    if (newData['isRaining'] == true &&
        data['isRaining'] == false &&
        newData['manualCanopy'] == false) {
      _sendAlert("☔ Weather Alert", "Rain detected. Canopy opening.");
    }
  }

  // --- 2. VOICE ASSISTANT ---
  void _startAssistant() async {
    if (!_voiceAssistantAvailable) {
      return;
    }

    try {
      final bool avail = await _speech.initialize();

      if (!mounted) {
        return;
      }

      if (avail) {
        _listenLoop();
      } else {
        setState(() => _voiceAssistantAvailable = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _voiceAssistantAvailable = false);
      }
    }
  }

  bool _containsWakeWord(String text) {
    return text.contains('sofi') ||
        text.contains('sofy') ||
        text.contains('sophie');
  }

  String _stripWakeWord(String text) {
    return text
        .replaceAll('sofi', '')
        .replaceAll('sofy', '')
        .replaceAll('sophie', '')
        .trim();
  }

  void _openCommandWindow() {
    _commandWindowTimer?.cancel();
    if (mounted) {
      setState(() => _isAwaitingCommand = true);
    }
    _commandWindowTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _isAwaitingCommand = false);
      }
    });
  }

  void _listenLoop() {
    try {
      _speech.listen(
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(minutes: 5),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        onResult: (val) => _processSpeech(val.recognizedWords.toLowerCase()),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _voiceAssistantAvailable = false);
      }
    }
  }

  void _processSpeech(String text) {
    final cmd = text.trim();
    if (cmd.isEmpty) return;

    if (_containsWakeWord(cmd)) {
      _openCommandWindow();
      final commandAfterWake = _stripWakeWord(cmd);
      if (commandAfterWake.isNotEmpty) {
        _processVoiceCommand(commandAfterWake);
      }
      return;
    }

    if (_isAwaitingCommand) {
      _processVoiceCommand(cmd);
      _openCommandWindow();
    }
  }

  void _processVoiceCommand(String cmd) {
    bool on =
        cmd.contains("on") || cmd.contains("light") || cmd.contains("open");
    bool off = cmd.contains("off") || cmd.contains("close");

    if (cmd.contains("bedroom")) {
      _toggle('toggle-light', {'name': 'Bedroom', 'state': on && !off});
    }
    if (cmd.contains("kitchen")) {
      _toggle('toggle-light', {'name': 'Kitchen', 'state': on && !off});
    }
    if (cmd.contains("living") || cmd.contains("couch")) {
      _toggle('toggle-light', {'name': 'Living Room', 'state': on && !off});
    }
    if (cmd.contains("garage") && cmd.contains("light")) {
      _toggle('toggle-light', {'name': 'Garage', 'state': on && !off});
    }
    if (cmd.contains("garage") && !cmd.contains("light")) {
      _toggle('toggle-garage', {'state': on && !off});
    }
    if (cmd.contains("canopy") || cmd.contains("balcony")) {
      _toggle('toggle-canopy', {'state': on && !off});
    }
    if (cmd.contains("pump") || cmd.contains("water")) {
      _toggle('toggle-pump', {'state': on && !off});
    }
  }

  // --- 3. DATA REFRESH ---
  Future<void> _fetchData() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/status'),
        headers: {'x-client-id': _clientId},
      );
      if (res.statusCode == 200 && mounted) {
        final newData = jsonDecode(res.body);
        _checkForAutomations(newData);
        setState(() {
          data = newData;
          _isServerOnline = true;
        });
        return;
      }

      if (mounted) {
        setState(() => _isServerOnline = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isServerOnline = false);
      }
    }
  }

  @override
  void dispose() {
    _commandWindowTimer?.cancel();
    _pollTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSystemAwake) {
      return GestureDetector(
        onTap: () {
          setState(() => _isSystemAwake = true);
          if (_voiceAssistantAvailable) {
            _startAssistant();
          }
        },
        child: Scaffold(
          body: Center(
            child: Icon(
              Icons.bolt_rounded,
              size: 100,
              color: Colors.blueAccent.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: [
            DashboardPage(
              data: data,
              isListening: _speech.isListening,
              isServerOnline: _isServerOnline,
            ),
            ControlPage(data: data, isListening: _speech.isListening),
            SettingsPage(data: data, isListening: _speech.isListening),
          ]),
          if (!_isServerOnline)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Server Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF02040A),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Status'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), label: 'Control'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
