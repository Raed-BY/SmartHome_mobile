import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for vibration feedback
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
  // Local state for immediate UI updates (optimistic updates)
  late bool _localPump;
  late bool _localGarage;
  late Map<String, bool> _localLights;

  @override
  void initState() {
    super.initState();
    _syncStateFromWidget();
  }

  @override
  void didUpdateWidget(covariant ControlPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep UI aligned with backend polling updates to avoid stale/inverted toggles.
    _syncStateFromWidget();
  }

  void _syncStateFromWidget() {
    _localPump = widget.data['manualPump'] ?? false;
    _localGarage = widget.data['garageOpen'] ?? false;
    _localLights = Map<String, bool>.from(widget.data['lights'] ?? {})
        .cast<String, bool>();
  }

  // --- 1. THE ACTION FUNCTION WITH OPTIMISTIC UPDATE ---
  Future<void> _toggle(String path, dynamic body) async {
    try {
      // Optimistically update local state first
      if (path == 'toggle-pump') {
        setState(() => _localPump = body['state'] ?? !_localPump);
      } else if (path == 'toggle-garage') {
        setState(() => _localGarage = body['state'] ?? !_localGarage);
      } else if (path == 'toggle-light' && body is Map) {
        setState(() {
          _localLights[body['name']] =
              body['state'] ?? !(_localLights[body['name']] ?? false);
        });
      }

      // Send POST to backend
      final res = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Success - no visual feedback needed (optimistic update already updated UI)
        debugPrint('Toggle $path succeeded: ${res.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$path sent successfully'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Error - revert optimistic update
        setState(() => _syncStateFromWidget());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Action failed (${res.statusCode})'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        debugPrint('Toggle $path failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      // Error - revert optimistic update
      setState(() => _syncStateFromWidget());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      debugPrint('Error toggling $path: $e');
    }
  }

  // Maps your rooms to your specific filenames
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
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;
    final double s = h < 780 ? 1.0 : 1.08;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 18 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: VOICE INDICATOR ---
              Padding(
                padding: EdgeInsets.fromLTRB(18 * s, 9, 18 * s, 11),
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                child: const Text("Control Hub",
                    style:
                        TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: h * 0.014),

              // --- 1. GARDEN PUMP ---
              _buildSwitchTile("Garden Water Pump", _localPump,
                  Icons.water_drop, Colors.blue, (v) {
                _toggle('toggle-pump', {'state': v});
              }, true),

              SizedBox(height: h * 0.01),

              // --- 2. GARAGE DOOR ---
              _buildSwitchTile("Garage Door", _localGarage, Icons.garage,
                  Colors.orangeAccent, (v) {
                _toggle('toggle-garage', {'state': v});
              }, false),

              SizedBox(height: h * 0.01),

              // --- 3. MAIN ENTRANCE DOOR (Action Button) ---
              _buildActionTile("Main Entrance Door", "TAP TO UNLOCK",
                  Icons.door_front_door_rounded, Colors.greenAccent, () {
                HapticFeedback.mediumImpact();
                _toggle('toggle-door', {'state': true});
              }),

              Padding(
                padding: EdgeInsets.fromLTRB(18 * s, 13, 18 * s, 9),
                child: const Text("Lights",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _localLights.keys.map((name) {
                    final bool isOn = _localLights[name] ?? false;
                    final double tileWidth = (w - (18 * s * 2) - 12) / 2;
                    return SizedBox(
                      width: tileWidth,
                      child: GestureDetector(
                        onTap: () => _toggle(
                            'toggle-light', {'name': name, 'state': !isOn}),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 132,
                          decoration: BoxDecoration(
                            color: isOn
                                ? Colors.blueAccent.withValues(alpha: 0.1)
                                : const Color(0xFF10141E),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: isOn
                                    ? Colors.blueAccent.withValues(alpha: 0.5)
                                    : Colors.transparent,
                                width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                _getIconPath(name),
                                height: 38,
                                color:
                                    isOn ? Colors.blueAccent : Colors.white24,
                                errorBuilder: (c, e, s) => Icon(Icons.lightbulb,
                                    size: 30,
                                    color:
                                        isOn ? Colors.yellow : Colors.white10),
                              ),
                              const SizedBox(height: 7),
                              Text(name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)),
                              Text(isOn ? "Active" : "OFF",
                                  style: TextStyle(
                                      color: isOn
                                          ? Colors.blueAccent
                                          : Colors.white10,
                                      fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE SWITCH TILE (For Pump, Canopy, Garage) ---
  Widget _buildSwitchTile(String title, bool val, IconData icon, Color color,
      Function(bool) onChanged, bool hasAuto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
          color: const Color(0xFF10141E),
          borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 22, color: val ? color : Colors.white10),
        title: Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(
            hasAuto
                ? (val ? "Manual Override: ON" : "Automatic Mode")
                : (val ? "OPEN" : "CLOSED"),
            style: const TextStyle(fontSize: 10.5)),
        trailing:
            Switch(value: val, activeThumbColor: color, onChanged: onChanged),
      ),
    );
  }

  // --- NEW: REUSABLE ACTION TILE (For Door Unlock) ---
  Widget _buildActionTile(String title, String sub, IconData icon, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, size: 22, color: color),
        title: Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(sub,
            style: TextStyle(
                fontSize: 10.5,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.lock_open, color: color),
          onPressed: onTap,
        ),
      ),
    );
  }
}
