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
    final String name = data['systemInfo']?['userName'] ?? 'User';
    final int gas = data['gasLevel'] ?? 0;
    final String lastVisitor = data['lastVisitor'] ?? 'No one at the door';

    // --- WATER PUMP REASON LOGIC ---
    // This checks if the pump is active (Soil < 30 or Manual ON)
    final bool isPumpActive = (data['soilMoisture'] ?? 0) < 30 || (data['manualPump'] == true);
    
    // This pulls the "weatherReason" we created in app.controller.ts
    // Example: "Rain expected (80%)" or "Soil is healthy"
    final String pumpStatusText = data['weatherReason'] ?? (isPumpActive ? "ACTIVE" : "OFF");

    final bool isCanopyActive = (data['isRaining'] == true) || (data['manualCanopy'] == true);
    final bool isGarageOpen = data['garageOpen'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
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
                          color: isListening ? Colors.greenAccent : Colors.white10,
                          boxShadow: isListening
                              ? [
                                  BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.4),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isServerOnline ? 'Server Online' : 'Server Offline',
                        style: TextStyle(
                          color: isServerOnline ? Colors.greenAccent : Colors.redAccent,
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
                        style: TextStyle(color: Colors.white38, fontSize: h * 0.0155)),
                    Text(name,
                        style: TextStyle(fontSize: h * 0.03, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SizedBox(height: h * 0.014),

              // 3. ENVIRONMENT CARDS (Main stats)
              _card("Living Room", "${data['tempSalon']}°C", Icons.thermostat, Colors.blue, h),
              SizedBox(height: h * 0.012),
              _card("Garden Soil", "${data['soilMoisture']}%", Icons.yard, Colors.green, h),

              SizedBox(height: h * 0.014),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Live Monitoring",
                      style: TextStyle(fontSize: h * 0.0185, fontWeight: FontWeight.bold))),
              SizedBox(height: h * 0.012),

              // 4. STICKER GRID (Monitoring)
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.18,
                  children: [
                    // --- SMART GARDEN PUMP STICKER ---
                    _sticker(
                        "Garden Pump",
                        pumpStatusText, // Shows: "Rain expected", "Soil healthy", etc.
                        Icons.water_drop,
                        isPumpActive ? Colors.blue : Colors.white10,
                        h),
                    _sticker(
                        "Balcony Canopy",
                        isCanopyActive ? "OPEN" : "CLOSED",
                        Icons.umbrella,
                        isCanopyActive ? Colors.orangeAccent : Colors.white10,
                        h),
                    _sticker(
                        "Garage",
                        isGarageOpen ? "OPEN" : "SECURED",
                        Icons.garage,
                        isGarageOpen ? Colors.orange : Colors.greenAccent,
                        h),
                    _sticker(
                        "Air Quality",
                        gas > 450 ? "GAS LEAK" : "SAFE",
                        Icons.gas_meter_rounded,
                        gas > 450 ? Colors.redAccent : Colors.greenAccent,
                        h),
                    _sticker("Visitor", lastVisitor, Icons.person, Colors.cyanAccent, h),
                    _sticker(
                        "Security",
                        data['motionDetected'] == true ? "ALERT" : "SAFE",
                        Icons.security,
                        data['motionDetected'] == true ? Colors.red : Colors.greenAccent,
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
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: h * 0.014),
        decoration: BoxDecoration(
            color: const Color(0xFF10141E),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(i, color: c, size: h * 0.022),
              const SizedBox(width: 11),
              Text(t, style: TextStyle(fontSize: h * 0.016))
            ]),
            Text(v, style: TextStyle(fontSize: h * 0.018, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  // Square stickers for the grid
  Widget _sticker(String label, String value, IconData icon, Color color, double h) =>
      Container(
        decoration: BoxDecoration(
            color: const Color(0xFF10141E),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: h * 0.029),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.white38, fontSize: h * 0.0122)),
            // Text alignment center to handle multiple lines for smart reasons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: h * 0.0132)),
            ),
          ],
        ),
      );
}