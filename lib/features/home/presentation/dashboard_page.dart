import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isListening;
  final bool isServerOnline;
  const DashboardPage(
      {super.key,
      required this.data,
      required this.isListening,
      required this.isServerOnline});

  @override
  Widget build(BuildContext context) {
    // Proportional scaling for different screen sizes
    final double h = MediaQuery.of(context).size.height;
    final double s = h < 780 ? 1.0 : 1.08;

    // Data Extraction
    final String name = data['systemInfo']?['userName'] ?? 'test';
    final int gas = data['gasLevel'] ?? 0;
    final bool smokeDanger = data['smokeDanger'] == true || gas > 3000;
    final String lastVisitor = data['lastVisitor'] ?? 'No one at the door';

    // --- WATER PUMP REASON LOGIC ---
    // Show pump as ON if it's actually on (regardless of manual or automatic mode)
    final bool isPumpActive = data['pump'] == true;

    final bool isRaining = data['isRaining'] == true;
    final String pumpStatusText =
        "${isPumpActive ? "ON" : "OFF"} - ${isRaining ? "RAIN" : "NO RAIN"}";

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s),
          child: Column(
            children: [
              // 1. TOP HEADER (Voice & Server Status)
              SizedBox(
                height: h * 0.03,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isListening ? Colors.greenAccent : Colors.white10,
                          boxShadow: isListening
                              ? [
                                  BoxShadow(
                                      color: Colors.greenAccent
                                          .withValues(alpha: 0.4),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isServerOnline ? 'Server Online' : 'Server Offline',
                        style: TextStyle(
                          color: isServerOnline
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: h * 0.0125,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. WELCOME SECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome home,",
                        style: TextStyle(
                            color: Colors.white38, fontSize: h * 0.014)),
                    Text(name,
                        style: TextStyle(
                            fontSize: h * 0.028, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SizedBox(height: h * 0.014),

              // 3. ENVIRONMENT CARDS (Main stats)
              _card("Living Room", "${data['tempSalon']}°C", Icons.thermostat,
                  Colors.blue, h),
              SizedBox(height: h * 0.01),
              _card("Garden Soil", "${data['soilMoisture']}%", Icons.yard,
                  Colors.green, h),

              SizedBox(height: h * 0.01),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Live Monitoring",
                      style: TextStyle(
                          fontSize: h * 0.017, fontWeight: FontWeight.bold))),
              SizedBox(height: h * 0.01),

              // 4. STICKER GRID (Monitoring)
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    // --- SMART GARDEN PUMP STICKER ---
                    _sticker("Garden Pump", pumpStatusText, Icons.water_drop,
                        isPumpActive ? Colors.blue : Colors.white10, h),
                    _sticker(
                        "Fire Detection",
                        smokeDanger ? "FIRE DETECTED" : "SAFE",
                        Icons.fire_extinguisher_rounded,
                        smokeDanger ? Colors.redAccent : Colors.greenAccent,
                        h),
                    _sticker("Visitor", lastVisitor, Icons.person,
                        Colors.cyanAccent, h),
                    _sticker(
                        "Security",
                        data['motionDetected'] == true ? "ALERT" : "SAFE",
                        Icons.security,
                        data['motionDetected'] == true
                            ? Colors.red
                            : Colors.greenAccent,
                        h),
                  ],
                ),
              ),

              SizedBox(height: h * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  // Large horizontal cards for Temp/Soil
  Widget _card(String t, String v, IconData i, Color c, double h) => Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: h * 0.0115),
        decoration: BoxDecoration(
            color: const Color(0xFF10141E),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(i, color: c, size: h * 0.02),
              const SizedBox(width: 9),
              Text(t, style: TextStyle(fontSize: h * 0.015))
            ]),
            Text(v,
                style: TextStyle(
                    fontSize: h * 0.017, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  // Square stickers for the grid
  Widget _sticker(
          String label, String value, IconData icon, Color color, double h) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFF10141E),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: h * 0.025),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: Colors.white38, fontSize: h * 0.0112)),
            // Text alignment center to handle multiple lines for smart reasons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: h * 0.0122)),
            ),
          ],
        ),
      );
}
