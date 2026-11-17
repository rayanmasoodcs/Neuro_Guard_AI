import 'package:flutter/material.dart';
import '../../services/language_service.dart';

/// NeuroGuard AI Dedicated Smartwatch / Wearable Companion Dashboard.
/// Designed specifically for Wear OS / wearable display viewports (< 320 dp).
/// Prioritizes:
/// 1. Device Connection & Sensor Status
/// 2. Current Patient Monitoring Status
/// 3. Active Alert State
/// 4. Protected Emergency SOS Action (with confirmation mechanism)
/// 5. Quick Alert Notifications
class SmartwatchDashboard extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  final LanguageProvider? languageProvider;

  const SmartwatchDashboard({
    super.key,
    this.patientData,
    this.languageProvider,
  });

  @override
  State<SmartwatchDashboard> createState() => _SmartwatchDashboardState();
}

class _SmartwatchDashboardState extends State<SmartwatchDashboard> {
  bool isConnected = true;
  bool isMonitoring = true;
  bool hasActiveAlert = false;
  String currentStatusText = "Monitoring Active";
  Color currentStatusColor = const Color(0xFF0B8F55);
  DateTime lastSyncTime = DateTime.now();

  void _triggerEmergencyConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text(
              "Trigger Emergency?",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Notify emergency contacts and send current location?",
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Emergency SOS Sent to Primary Caregiver"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text("SEND SOS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientData?['name'] ?? "Patient";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. WATCH TOP HEADER & DEVICE STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.greenAccent : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? "SENSOR CONNECTED" : "DISCONNECTED",
                    style: TextStyle(
                      color: isConnected ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 2. CURRENT MONITORING STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: currentStatusColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      hasActiveAlert ? Icons.warning_rounded : Icons.check_circle_rounded,
                      color: currentStatusColor,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStatusText.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Patient: $patientName",
                      style: const TextStyle(color: Colors.white60, fontSize: 9),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 3. EMERGENCY SOS BUTTON (PROTECTED 2-STEP TARGET)
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _triggerEmergencyConfirmation,
                  icon: const Icon(Icons.emergency_rounded, color: Colors.white, size: 16),
                  label: const Text(
                    "EMERGENCY SOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 4. QUICK ACTION TOGGLE & SYNC TIMESTAMPS
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Live Stream", style: TextStyle(color: Colors.white70, fontSize: 9)),
                        Text("256 Hz EEG", style: TextStyle(color: Colors.white38, fontSize: 8)),
                      ],
                    ),
                    Switch(
                      value: isMonitoring,
                      activeThumbColor: const Color(0xFF0B8F55),
                      onChanged: (val) {
                        setState(() {
                          isMonitoring = val;
                          currentStatusText = val ? "Monitoring Active" : "Paused";
                          currentStatusColor = val ? const Color(0xFF0B8F55) : Colors.orangeAccent;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Text(
                "Last Sync: ${lastSyncTime.hour}:${lastSyncTime.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
