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
  bool _assistantEnabled = false;
  bool _isResolvingEndpoint = false;
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
    if (_assistantEnabled) {
      _speech.stop();
      if (mounted) {
        setState(() => _assistantEnabled = false);
      }
      return;
    }

    if (!await _ensureAssistantReady()) {
      return;
    }

    _assistantEnabled = true;
    _listenLoop();
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _ensureAssistantReady() async {
    if (!_voiceAssistantAvailable) {
      return false;
    }

    try {
      final bool avail = await _speech.initialize(
        onStatus: (status) {
          // Android can stop listening automatically; restart while assistant is enabled.
          if (_assistantEnabled && status == 'done') {
            _listenLoop();
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _assistantEnabled = false;
            });
          }
        },
      );

      if (!mounted) {
        return false;
      }

      if (avail) {
        return true;
      } else {
        setState(() => _voiceAssistantAvailable = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice assistant is unavailable on this device.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _voiceAssistantAvailable = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for assistant.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
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
    if (!_assistantEnabled) {
      return;
    }

    try {
      _speech.listen(
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 4),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        onResult: (val) => _processSpeech(val.recognizedWords.toLowerCase()),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _assistantEnabled = false);
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
      return;
    }

    if (_looksLikeDirectCommand(cmd)) {
      _processVoiceCommand(cmd);
    }
  }

  bool _looksLikeDirectCommand(String cmd) {
    return cmd.contains('bedroom') ||
        cmd.contains('kitchen') ||
        cmd.contains('living') ||
        cmd.contains('garage') ||
        cmd.contains('pump') ||
        cmd.contains('water') ||
        cmd.contains('canopy') ||
        cmd.contains('balcony') ||
        cmd.contains('light');
  }

  void _processVoiceCommand(String cmd) {
    final on = RegExp(r'\b(on|open|start|enable)\b').hasMatch(cmd);
    final off = RegExp(r'\b(off|close|stop|disable)\b').hasMatch(cmd);
    final shouldTurnOn = on && !off;
    final shouldTurnOff = off && !on;

    if (!shouldTurnOn && !shouldTurnOff) {
      return;
    }

    final state = shouldTurnOn;

    if (cmd.contains("bedroom")) {
      _toggle('toggle-light', {'name': 'Bedroom', 'state': state});
    }
    if (cmd.contains("kitchen")) {
      _toggle('toggle-light', {'name': 'Kitchen', 'state': state});
    }
    if (cmd.contains("living") || cmd.contains("couch")) {
      _toggle('toggle-light', {'name': 'Living Room', 'state': state});
    }
    if (cmd.contains("garage") && cmd.contains("light")) {
      _toggle('toggle-light', {'name': 'Garage', 'state': state});
    }
    if (cmd.contains("garage") && !cmd.contains("light")) {
      _toggle('toggle-garage', {'state': state});
    }
    if (cmd.contains("canopy") || cmd.contains("balcony")) {
      _toggle('toggle-canopy', {'state': state});
    }
    if (cmd.contains("pump") || cmd.contains("water")) {
      _toggle('toggle-pump', {'state': state});
    }
  }

  // --- 3. DATA REFRESH ---
  Future<void> _fetchData() async {
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        final res = await http.get(
          Uri.parse('${AppConfig.baseUrl}/status'),
          headers: {'x-client-id': _clientId},
        ).timeout(const Duration(seconds: 6));

        if (res.statusCode == 200 && mounted) {
          final newData = jsonDecode(res.body);
          _checkForAutomations(newData);
          setState(() {
            data = newData;
            _isServerOnline = true;
          });
          return;
        }
      }

      final switched = await _switchToReachableBaseUrl();
      if (switched) {
        await _fetchData();
        return;
      }

      if (mounted) setState(() => _isServerOnline = false);
    } catch (_) {
      final switched = await _switchToReachableBaseUrl();
      if (switched) {
        await _fetchData();
        return;
      }

      if (mounted) {
        setState(() => _isServerOnline = false);
      }
    }
  }

  Future<bool> _switchToReachableBaseUrl() async {
    if (_isResolvingEndpoint) {
      return false;
    }

    _isResolvingEndpoint = true;
    try {
      final current = AppConfig.baseUrl;
      final candidates = AppConfig.mobileBaseUrlCandidates.toSet();

      for (final base in candidates) {
        if (base == current) continue;

        try {
          final res = await http.get(
            Uri.parse('$base/status'),
            headers: {'x-client-id': _clientId},
          ).timeout(const Duration(seconds: 3));

          if (res.statusCode == 200) {
            AppConfig.setMobileBaseUrl(base);
            return true;
          }
        } catch (_) {}
      }

      return false;
    } finally {
      _isResolvingEndpoint = false;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 100,
                  color: Colors.blueAccent.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap to wake SmartHome',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E1623), Color(0xFF0A101A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _navChip(0, Icons.dashboard_rounded, 'Status'),
              _navChip(1, Icons.lightbulb_outline, 'Control'),
              _navChip(2, Icons.settings_rounded, 'Settings'),
              _voiceChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navChip(int index, IconData icon, String label) {
    final selected = _index == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _index = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 21, color: selected ? Colors.white : Colors.white54),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceChip() {
    final enabled = _assistantEnabled && _speech.isListening;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _startAssistant,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? Colors.greenAccent.withValues(alpha: 0.6)
                : Colors.white24,
          ),
        ),
        child: Icon(
          enabled ? Icons.mic : Icons.mic_none,
          size: 20,
          color: enabled ? Colors.greenAccent : Colors.white70,
        ),
      ),
    );
  }
}
