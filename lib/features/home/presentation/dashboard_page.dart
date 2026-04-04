import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  const DashboardPage({super.key, required this.data, required this.isListening});

  @override
  Widget build(BuildContext context) {
    // We use the screen height to make everything proportional
    final double h = MediaQuery.of(context).size.height;
    final String name = data['systemInfo']?['userName'] ?? 'User';
    final int gas = data['gasLevel'] ?? 0;
    
    final bool isPumpActive = (data['soilMoisture'] ?? 0) < 30 || (data['manualPump'] == true);
    final bool isCanopyActive = (data['isRaining'] == true) || (data['manualCanopy'] == true);
    final bool isGarageOpen = data['garageOpen'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // 1. TOP HEADER (Green Dot) - Minimal Height
              SizedBox(
                height: h * 0.04,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? Colors.greenAccent : Colors.white10,
                      boxShadow: isListening ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 10)] : [],
                    ),
                  ),
                ),
              ),

              // 2. WELCOME (Proportional font)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome home,", style: TextStyle(color: Colors.white38, fontSize: h * 0.018)),
                    Text(name, style: TextStyle(fontSize: h * 0.035, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // 3. ENVIRONMENT CARDS (Flexible height)
              _card("Living Room", "${data['tempSalon']}°C", Icons.thermostat, Colors.blue, h),
              SizedBox(height: h * 0.015),
              _card("Garden Soil", "${data['soilMoisture']}%", Icons.yard, Colors.green, h),

              SizedBox(height: h * 0.025),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Live Monitoring", style: TextStyle(fontSize: h * 0.02, fontWeight: FontWeight.bold))
              ),
              SizedBox(height: h * 0.015),

              // 4. STICKER GRID (Wrapped in Flexible to avoid the yellow bar)
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1, // Adjusted to balance height
                  children: [
                    _sticker("Garden Pump", isPumpActive ? "ACTIVE" : "OFF", Icons.water_drop, isPumpActive ? Colors.blue : Colors.white10, h),
                    _sticker("Balcony Canopy", isCanopyActive ? "OPEN" : "CLOSED", Icons.umbrella, isCanopyActive ? Colors.orangeAccent : Colors.white10, h),
                    _sticker("Garage", isGarageOpen ? "OPEN" : "SECURED", Icons.garage, isGarageOpen ? Colors.orange : Colors.greenAccent, h),
                    _sticker("Security", data['motionDetected'] == true ? "ALERT" : "SAFE", Icons.security, data['motionDetected'] == true ? Colors.red : Colors.greenAccent, h),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // 5. GAS MONITORING (Flexible/Bottom)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.02),
                margin: EdgeInsets.only(bottom: h * 0.02),
                decoration: BoxDecoration(
                  color: gas > 450 ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF10141E),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: gas > 450 ? Colors.redAccent : Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.gas_meter_rounded, color: gas > 450 ? Colors.redAccent : Colors.orangeAccent, size: h * 0.035),
                    SizedBox(height: h * 0.005),
                    Text(
                      gas > 450 ? "GAS LEAK DETECTED" : "AIR QUALITY SAFE", 
                      style: TextStyle(fontSize: h * 0.015, fontWeight: FontWeight.w900, color: gas > 450 ? Colors.redAccent : Colors.greenAccent)
                    ),
                    Text("$gas ppm", style: TextStyle(color: Colors.white38, fontSize: h * 0.013)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String t, String v, IconData i, Color c, double h) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: h * 0.018),
    decoration: BoxDecoration(color: const Color(0xFF10141E), borderRadius: BorderRadius.circular(25)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [Icon(i, color: c, size: h * 0.025), const SizedBox(width: 15), Text(t, style: TextStyle(fontSize: h * 0.017))]),
        Text(v, style: TextStyle(fontSize: h * 0.02, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _sticker(String l, String v, IconData i, Color c, double h) => Container(
    decoration: BoxDecoration(color: const Color(0xFF10141E), borderRadius: BorderRadius.circular(25)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(i, color: c, size: h * 0.035),
        const SizedBox(height: 8),
        Text(l, style: TextStyle(color: Colors.white38, fontSize: h * 0.013)),
        Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: h * 0.014)),
      ],
    ),
  );
}
