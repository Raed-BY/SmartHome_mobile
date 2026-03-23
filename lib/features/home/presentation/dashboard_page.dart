import 'package:flutter/material.dart';

// Live status dashboard.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.data});

  // Status payload received from backend.
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    // User name from system info.
    final String name = data['systemInfo']?['userName'] ?? 'User';
    // Pump considered active either by auto-rule or manual override.
    final bool isPumpActive =
        (data['soilMoisture'] ?? 0) < 30 || (data['manualPump'] == true);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          25, MediaQuery.of(context).padding.top + 40, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome home,',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          Text(name,
              style:
                  const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // Main metric cards.
          _card('Living Room', '${data['tempSalon']}°C', Icons.thermostat,
              Colors.blue),
          const SizedBox(height: 15),
          _card('Garden Soil', '${data['soilMoisture']}%', Icons.yard,
              Colors.green),
          const SizedBox(height: 35),
          const Text(
            'Live Monitoring',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // Monitoring stickers grid.
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            children: [
              _sticker(
                'Garden Pump',
                isPumpActive ? 'ACTIVE' : 'OFF',
                Icons.water_drop,
                isPumpActive ? Colors.blue : Colors.white10,
              ),
              _sticker(
                'Gas',
                '${data['gasLevel']}',
                Icons.gas_meter,
                (data['gasLevel'] ?? 0) > 400 ? Colors.red : Colors.orange,
              ),
              _sticker(
                'Security',
                data['motionDetected'] == true ? 'ALERT' : 'SAFE',
                Icons.security,
                data['motionDetected'] == true
                    ? Colors.orange
                    : Colors.greenAccent,
              ),
              _sticker(
                'Rain',
                data['isRaining'] == true ? 'YES' : 'NO',
                Icons.cloud,
                Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable large metric card.
  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Reusable compact status tile.
  Widget _sticker(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
