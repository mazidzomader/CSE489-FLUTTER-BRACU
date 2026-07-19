import 'dart:async';
import 'package:flutter/material.dart';
import 'broadcast_page.dart';

/// ===========================================================================
/// ACTIVITY 2 (OPTION 2): BATTERY BROADCAST RECEIVER (`BatteryNotificationReceiverActivity`)
/// Receives battery percentage broadcast and displays real-time status.
/// Extracted to separate file per user request with 0 padding and sharp edges.
/// ===========================================================================
class BatteryNotificationReceiverActivity extends StatefulWidget {
  const BatteryNotificationReceiverActivity({super.key});

  @override
  State<BatteryNotificationReceiverActivity> createState() =>
      _BatteryNotificationReceiverActivityState();
}

class _BatteryNotificationReceiverActivityState
    extends State<BatteryNotificationReceiverActivity> {
  late int _batteryLevel;
  StreamSubscription<int>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    _batteryLevel = BroadcastManager.instance.currentBatteryLevel;
    // Register system battery notification broadcast receiver
    _batterySubscription = BroadcastManager.instance.batteryBroadcastStream
        .listen((newLevel) {
          if (mounted) {
            setState(() {
              _batteryLevel = newLevel;
            });
          }
        });
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  Color _getBatteryColor(int level) {
    if (level <= 20) return Colors.red;
    if (level <= 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 2: Battery Broadcast Receiver'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBatteryColor(
                          _batteryLevel,
                        ).withValues(alpha: 0.15),
                        shape: BoxShape.rectangle,
                      ),
                      child: Icon(
                        _batteryLevel > 80
                            ? Icons.battery_full
                            : _batteryLevel > 50
                            ? Icons.battery_6_bar
                            : _batteryLevel > 20
                            ? Icons.battery_3_bar
                            : Icons.battery_alert,
                        size: 64,
                        color: _getBatteryColor(_batteryLevel),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'System Battery Notification Receiver',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Displays your device\'s real battery level. Updates automatically when charging state changes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Battery Percentage: ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$_batteryLevel%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _getBatteryColor(_batteryLevel),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
