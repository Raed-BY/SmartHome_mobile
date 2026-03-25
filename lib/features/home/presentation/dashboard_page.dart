import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  const DashboardPage({super.key, required this.data, required this.isListening});

  @override
  Widget build(BuildContext context) {
    final String name = data['systemInfo']?['userName'] ?? 'User';
    final int gas = data['gasLevel'] ?? 0;
    
    // Pump Logic
    final bool isPumpActive = (data['soilMoisture'] ?? 0) < 30 || (data['manualPump'] == true);
    // Canopy Logic
    final bool isCanopyActive = (data['isRaining'] == true) || (data['manualCanopy'] == true);
    // Garage Logic
    final bool isGarageOpen = data['garageOpen'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP HEADER (Green Dot Only) ---
            Padding(
              padding: EdgeInsets.fromLTRB(25, MediaQuery.of(context).padding.top + 10, 25, 10),
              child: Align(
                alignment: Alignment.topRight, 
                child: Container(
                  width: 8, height: 8, 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: isListening ? Colors.greenAccent : Colors.white10,
                    boxShadow: isListening ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 10)] : [],
                  )
                )
              ),
            ),
            
            // --- WELCOME ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Welcome home,", style: TextStyle(color: Colors.white38, fontSize: 16)),
                Text(name, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              ]),
            ),

            const SizedBox(height: 25),

            // --- LARGE CARDS ---
            _card("Living Room", "${data['tempSalon']}°C", Icons.thermostat, Colors.blue),
            const SizedBox(height: 15),
            _card("Garden Soil", "${data['soilMoisture']}%", Icons.yard, Colors.green),
            
            const SizedBox(height: 35),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25), 
              child: Text("Live Monitoring", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 15),

            // --- THE STICKER GRID ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, 
                crossAxisSpacing: 15, 
                mainAxisSpacing: 15,
                children: [
                  _sticker("Garden Pump", isPumpActive ? "ACTIVE" : "OFF", Icons.water_drop, isPumpActive ? Colors.blue : Colors.white10),
                  _sticker("Balcony Canopy", isCanopyActive ? "OPEN" : "CLOSED", Icons.umbrella, isCanopyActive ? Colors.orangeAccent : Colors.white10),
                  _sticker("Garage", isGarageOpen ? "OPEN" : "SECURED", Icons.garage, isGarageOpen ? Colors.orange : Colors.greenAccent),
                  _sticker("Security", data['motionDetected'] == true ? "ALERT" : "SAFE", Icons.security, data['motionDetected'] == true ? Colors.red : Colors.greenAccent),
                ],
              ),
            ),

            const SizedBox(height: 15), // Gap between Grid and Gas Card

            // --- GAS MONITORING CARD (CENTERED & SLEEK) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: gas > 450 ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF10141E),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: gas > 450 ? Colors.redAccent : Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.gas_meter_rounded, 
                      color: gas > 450 ? Colors.redAccent : Colors.orangeAccent, 
                      size: 35
                    ),
                    const SizedBox(height: 15),
                    Text(
                      gas > 450 ? "GAS LEAK DETECTED" : "AIR QUALITY SAFE", 
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w800, 
                        color: gas > 450 ? Colors.redAccent : Colors.greenAccent,
                        letterSpacing: 1.2
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$gas ppm", 
                      style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50), // Bottom breathing room
          ],
        ),
      ),
    );
  }

  // Reusable card for Temp/Soil
  Widget _card(String t, String v, IconData i, Color c) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 25),
    padding: const EdgeInsets.all(22), 
    decoration: BoxDecoration(
      color: const Color(0xFF10141E), 
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Row(children: [Icon(i, color: c), const SizedBox(width: 15), Text(t)]), 
        Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ]
    )
  );

  // Reusable sticker for the grid
  Widget _sticker(String l, String v, IconData i, Color c) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF10141E), 
      borderRadius: BorderRadius.circular(25)
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Icon(i, color: c, size: 32), 
        const SizedBox(height: 10), 
        Text(l, style: const TextStyle(color: Colors.white38, fontSize: 11)), 
        Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold))
      ]
    )
  );
}