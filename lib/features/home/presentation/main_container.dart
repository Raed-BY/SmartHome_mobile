import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/features/home/presentation/control_page.dart';
import 'package:mobile_app/features/home/presentation/dashboard_page.dart';
import 'package:mobile_app/features/home/presentation/settings_page.dart';

// Main shell with bottom navigation and live data polling.
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  // Selected tab index.
  int _index = 0;

  // Shared data model consumed by dashboard/control/settings.
  Map<String, dynamic> data = {
    'tempSalon': 0,
    'soilMoisture': 0,
    'gasLevel': 0,
    'isRaining': false,
    'motionDetected': false,
    'manualPump': false,
    'lights': { // Ajoute ça ici pour éviter les erreurs au démarrage
    'Living Room': false,
    'Bedroom': false,
    'Kitchen': false,
    'Garage': false,
  },
    'systemInfo': {'userName': 'User'},
  };

  // Timer for periodic API refresh.
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refreshes status every 2 seconds.
    _timer =
        Timer.periodic(const Duration(seconds: 2), (timer) => _fetchData());
  }

  // Loads latest smart-home status from backend.
  Future<void> _fetchData() async {
    try {
      final http.Response response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/status'));
      // Ignore invalid responses or disposed widget state.
      if (response.statusCode != 200 || !mounted) {
        return;
      }
      // Updates UI with decoded JSON payload.
      setState(() => data = jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {}
  }

  @override
  void dispose() {
    // Stops periodic polling.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pages rendered by bottom navigation.
    final List<Widget> pages = [
      DashboardPage(data: data),
      ControlPage(data: data),
      SettingsPage(data: data),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        // Switches between tabs.
        onTap: (index) => setState(() => _index = index),
        backgroundColor: const Color(0xFF02040A),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
