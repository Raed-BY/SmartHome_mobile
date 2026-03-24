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
  Future<void> _toggle(String path, dynamic body) async {
    try { await http.post(Uri.parse('${AppConfig.baseUrl}/$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: EdgeInsets.fromLTRB(25, MediaQuery.of(context).padding.top + 10, 25, 20),
              child: Align(alignment: Alignment.topRight, child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.isListening ? Colors.greenAccent : Colors.white10))),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: Text("Control Hub", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),
            _tile("Garden Water Pump", pump, Icons.water_drop, Colors.blue, (v) => _toggle('toggle-pump', {'state': v}), true),
            _tile("Balcony Canopy", canopy, Icons.umbrella, Colors.orangeAccent, (v) => _toggle('toggle-canopy', {'state': v}), true),
            _tile("Garage Door", garage, Icons.garage, Colors.orangeAccent, (v) => _toggle('toggle-garage', {'state': v}), false),
            const Padding(padding: EdgeInsets.fromLTRB(25, 30, 25, 15), child: Text("Lights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            GridView.count(
              shrinkWrap: true, padding: const EdgeInsets.symmetric(horizontal: 25),
              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85,
              children: lights.keys.map((n) {
                bool isOn = lights[n] ?? false;
                return GestureDetector(
                  onTap: () => _toggle('toggle-light', {'name': n, 'state': !isOn}),
                  child: Container(decoration: BoxDecoration(color: isOn ? Colors.blueAccent.withOpacity(0.1) : const Color(0xFF10141E), borderRadius: BorderRadius.circular(25), border: Border.all(color: isOn ? Colors.blueAccent.withOpacity(0.5) : Colors.transparent)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.network('icons/${n == 'Living Room' ? 'couch' : n.toLowerCase()}.png', height: 45, color: isOn ? Colors.blueAccent : Colors.white24, errorBuilder: (c,e,s) => Icon(Icons.lightbulb, color: isOn ? Colors.yellow : Colors.white10)),
                      const SizedBox(height: 10), Text(n, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ])),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String t, bool v, IconData i, Color c, Function(bool) fn, bool auto) => Container(
    margin: const EdgeInsets.fromLTRB(25, 0, 25, 12), decoration: BoxDecoration(color: const Color(0xFF10141E), borderRadius: BorderRadius.circular(20)),
    child: ListTile(leading: Icon(i, color: v ? c : Colors.white10), title: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), subtitle: Text(auto ? (v ? "Manual Override: ON" : "Automatic Mode") : (v ? "OPEN" : "CLOSED"), style: const TextStyle(fontSize: 11)), trailing: Switch(value: v, activeColor: c, onChanged: fn)));
}