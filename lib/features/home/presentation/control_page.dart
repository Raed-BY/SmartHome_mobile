import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/app_config.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  
  // Fonction pour envoyer les changements au serveur
  Future<void> _toggleServerDevice(String endpoint, Map<String, dynamic> body) async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('Error toggling device: $e');
    }
  }

  String _getIconPath(String name) {
    switch (name) {
      case 'Living Room': return 'icons/couch.png';
      case 'Bedroom': return 'icons/bedroom.png';
      case 'Kitchen': return 'icons/kitchen.png';
      case 'Garage': return 'icons/garage.png';
      default: return 'icons/bolt.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lecture des états depuis les données du serveur
    final bool pump = widget.data['manualPump'] ?? false;
    final Map<String, dynamic> serverLights = widget.data['lights'] ?? {
      'Living Room': false,
      'Bedroom': false,
      'Kitchen': false,
      'Garage': false,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(25, MediaQuery.of(context).padding.top + 40, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Control Hub', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          
          // --- BOUTON POMPE ---
          Container(
            decoration: BoxDecoration(color: const Color(0xFF10141E), borderRadius: BorderRadius.circular(25)),
            child: ListTile(
              leading: Icon(Icons.water_drop_rounded, color: pump ? Colors.blue : Colors.white10),
              title: const Text('Garden Water Pump', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(pump ? 'Manual Mode: ON' : 'Automatic Mode'),
              trailing: Switch(
                value: pump,
                activeColor: Colors.blueAccent,
                onChanged: (value) => _toggleServerDevice('toggle-pump', {'state': value}),
              ),
            ),
          ),

          const SizedBox(height: 35),
          const Text('Lights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- GRILLE DES LUMIERES ---
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.85,
            children: serverLights.keys.map((name) {
              final bool isOn = serverLights[name] ?? false;
              return GestureDetector(
                onTap: () => _toggleServerDevice('toggle-light', {'name': name, 'state': !isOn}),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isOn ? Colors.blueAccent.withOpacity(0.1) : const Color(0xFF10141E),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isOn ? Colors.blueAccent.withOpacity(0.5) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        _getIconPath(name),
                        height: 50, width: 50,
                        color: isOn ? Colors.blueAccent : Colors.white24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.lightbulb_outline),
                      ),
                      const SizedBox(height: 15),
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(isOn ? 'Active' : 'Tap to toggle', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}