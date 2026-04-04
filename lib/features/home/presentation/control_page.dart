import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

class ControlPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  const ControlPage({super.key, required this.data, required this.isListening});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // --- 1. THE ACTION FUNCTION (Now used below) ---
  Future<void> _toggle(String path, dynamic body) async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  // Maps your rooms to your specific filenames in web/icons
  String _getIconPath(String name) {
    switch (name) {
      case 'Living Room':
        return 'assets/icons/couch.png';
      case 'Bedroom':
        return 'assets/icons/bedroom.png';
      case 'Kitchen':
        return 'assets/icons/kitchen.png';
      case 'Garage':
        return 'assets/icons/garage.png';
      default:
        return 'assets/icons/app_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract server data
    final bool pump = widget.data['manualPump'] ?? false;
    final bool canopy = widget.data['manualCanopy'] ?? false;
    final bool garage = widget.data['garageOpen'] ?? false;
    final Map<String, dynamic> lights = widget.data['lights'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: GREEN DOT ---
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
                    color: widget.isListening
                        ? Colors.greenAccent
                        : Colors.white10,
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("Control Hub",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 25),

            // --- 1. GARDEN PUMP ---
            _buildSwitchTile(
                "Garden Water Pump", pump, Icons.water_drop, Colors.blue, (v) {
              _toggle('toggle-pump', {'state': v}); // <--- _toggle used here
            }, true),

            // --- 2. BALCONY CANOPY ---
            _buildSwitchTile(
                "Balcony Canopy", canopy, Icons.umbrella, Colors.orangeAccent,
                (v) {
              _toggle('toggle-canopy', {'state': v}); // <--- _toggle used here
            }, true),

            // --- 3. GARAGE DOOR ---
            _buildSwitchTile(
                "Garage Door", garage, Icons.garage, Colors.orangeAccent, (v) {
              _toggle('toggle-garage', {'state': v}); // <--- _toggle used here
            }, false),

            const Padding(
              padding: EdgeInsets.fromLTRB(25, 35, 25, 15),
              child: Text("Lights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // --- 4. LIGHTS GRID (ROOMS) ---
            GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: lights.keys.map((name) {
                bool isOn = lights[name] ?? false;
                return GestureDetector(
                  onTap: () {
                    _toggle('toggle-light', {
                      'name': name,
                      'state': !isOn
                    }); // <--- _toggle used here
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isOn
                          ? Colors.blueAccent.withOpacity(0.1)
                          : const Color(0xFF10141E),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: isOn
                              ? Colors.blueAccent.withOpacity(0.5)
                              : Colors.transparent,
                          width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _getIconPath(name),
                          height: 45,
                          color: isOn ? Colors.blueAccent : Colors.white24,
                          errorBuilder: (c, e, s) => Icon(Icons.lightbulb,
                              color: isOn ? Colors.yellow : Colors.white10),
                        ),
                        const SizedBox(height: 12),
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(isOn ? "Active" : "OFF",
                            style: TextStyle(
                                color:
                                    isOn ? Colors.blueAccent : Colors.white10,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool val, IconData icon, Color color,
      Function(bool) onChanged, bool hasAuto) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 12),
      decoration: BoxDecoration(
          color: const Color(0xFF10141E),
          borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: val ? color : Colors.white10),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(
          hasAuto
              ? (val ? "Manual Override: ON" : "Automatic Mode")
              : (val ? "OPEN" : "CLOSED"),
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Switch(
          value: val,
          activeColor: color,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
