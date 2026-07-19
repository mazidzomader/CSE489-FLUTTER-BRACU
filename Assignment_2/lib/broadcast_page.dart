import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'main.dart';
import 'battery_notification_page.dart';

/// ===========================================================================
/// BROADCAST RECEIVER SERVICE & STATE MANAGEMENT
/// Emulates Android's LocalBroadcastManager and System Battery Broadcasts
/// following Android Jetpack / reactive stream design philosophy.
/// ===========================================================================
class BroadcastManager {
  BroadcastManager._privateConstructor() {
    _initRealBattery();
  }
  static final BroadcastManager instance =
      BroadcastManager._privateConstructor();

  // 1. Custom Broadcast Receiver Stream (`StreamController.broadcast`)
  final StreamController<String> _customBroadcastController =
      StreamController<String>.broadcast();
  Stream<String> get customBroadcastStream => _customBroadcastController.stream;

  void sendCustomBroadcast(String message) {
    _customBroadcastController.add(message);
  }

  // 2. Real System Battery Stream using battery_plus
  final Battery _battery = Battery();
  final StreamController<int> _batteryBroadcastController =
      StreamController<int>.broadcast();
  Stream<int> get batteryBroadcastStream => _batteryBroadcastController.stream;

  int _currentBatteryLevel = 0;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  void _initRealBattery() {
    // Fetch the real battery level immediately on init
    _battery.batteryLevel.then((level) {
      _currentBatteryLevel = level;
      _batteryBroadcastController.add(_currentBatteryLevel);
    });

    // Listen for battery state changes (charging/discharging) and re-read level
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      state,
    ) async {
      final level = await _battery.batteryLevel;
      _currentBatteryLevel = level;
      _batteryBroadcastController.add(_currentBatteryLevel);
    });
  }

  void dispose() {
    _batteryStateSubscription?.cancel();
    _customBroadcastController.close();
    _batteryBroadcastController.close();
  }

  int get currentBatteryLevel => _currentBatteryLevel;
}

/// ===========================================================================
/// ACTIVITY 1: BROADCAST RECEIVER SELECTION (`BroadcastReceiverSelectionActivity`)
/// Shows Spinner dropdown with 2 options and Proceed button.
/// ===========================================================================
enum BroadcastOption {
  custom('Custom broadcast receiver'),
  battery('System battery notification receiver');

  final String label;
  const BroadcastOption(this.label);
}

class BroadcastReceiverSelectionActivity extends StatefulWidget {
  const BroadcastReceiverSelectionActivity({super.key});

  @override
  State<BroadcastReceiverSelectionActivity> createState() =>
      _BroadcastReceiverSelectionActivityState();
}

class _BroadcastReceiverSelectionActivityState
    extends State<BroadcastReceiverSelectionActivity> {
  BroadcastOption _selectedOption = BroadcastOption.custom;

  void _proceedToNextActivity() {
    if (_selectedOption == BroadcastOption.custom) {
      // Option 1 -> Activity 2 (Takes plain text input to pass to Activity 3)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomBroadcastInputActivity()),
      );
    } else {
      // Option 2 -> Activity 2 (Receives battery percentage broadcast)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BatteryNotificationReceiverActivity(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity 1: Select Broadcast')),
      drawer: const AppNavigationDrawer(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Broadcast Operation Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select from the spinner below which broadcast workflow you wish to execute:',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Spinner (Dropdown Selection):',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.zero,
                        color: Colors.blue.shade50.withValues(alpha: 0.3),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BroadcastOption>(
                          value: _selectedOption,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Color(0xFF1E88E5),
                          ),
                          items: BroadcastOption.values.map((option) {
                            return DropdownMenuItem<BroadcastOption>(
                              value: option,
                              child: Row(
                                children: [
                                  Icon(
                                    option == BroadcastOption.custom
                                        ? Icons.message
                                        : Icons.battery_charging_full,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (BroadcastOption? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedOption = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: _proceedToNextActivity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Proceed to Next Activity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
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

/// ===========================================================================
/// ACTIVITY 2 (OPTION 1): CUSTOM BROADCAST INPUT (`CustomBroadcastInputActivity`)
/// Takes plain text input and passes it to Activity 3 via Custom Broadcast / Intent.
/// ===========================================================================
class CustomBroadcastInputActivity extends StatefulWidget {
  const CustomBroadcastInputActivity({super.key});

  @override
  State<CustomBroadcastInputActivity> createState() =>
      _CustomBroadcastInputActivityState();
}

class _CustomBroadcastInputActivityState
    extends State<CustomBroadcastInputActivity> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendBroadcastAndLaunchActivity3() {
    if (_formKey.currentState!.validate()) {
      final textInput = _textController.text.trim();

      // 1. Emit the custom broadcast message over our reactive Jetpack event bus
      BroadcastManager.instance.sendCustomBroadcast(textInput);

      // 2. Navigate to Activity 3 (Custom Broadcast Receiver screen) passing text
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomBroadcastReceiverActivity(initialTextPayload: textInput),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity 2: Input Text Message')),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: const Icon(
                              Icons.send_to_mobile,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Send Custom Broadcast',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This activity takes plain text input from the user and broadcasts it to the Custom Broadcast Receiver in Activity 3.',
                        style: TextStyle(color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: 'Enter Plain Text Message',
                          hintText: 'e.g. Hello from Activity 2 Broadcast!',
                          prefixIcon: const Icon(Icons.short_text),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xFF1E88E5),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter some text to broadcast.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          icon: const Icon(Icons.podcasts),
                          label: const Text(
                            'Send Broadcast',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _sendBroadcastAndLaunchActivity3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// ACTIVITY 3: CUSTOM BROADCAST RECEIVER ACTIVITY (`CustomBroadcastReceiverActivity`)
/// Receives custom broadcast text message given in Activity 2.
/// For Option 2 (battery), does nothing per requirement.
/// ===========================================================================
class CustomBroadcastReceiverActivity extends StatefulWidget {
  final String? initialTextPayload;
  const CustomBroadcastReceiverActivity({super.key, this.initialTextPayload});

  @override
  State<CustomBroadcastReceiverActivity> createState() =>
      _CustomBroadcastReceiverActivityState();
}

class _CustomBroadcastReceiverActivityState
    extends State<CustomBroadcastReceiverActivity> {
  String _receivedMessage = 'Waiting for broadcast message...';
  String _timestamp = '';
  StreamSubscription<String>? _broadcastSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.initialTextPayload != null &&
        widget.initialTextPayload!.isNotEmpty) {
      _receivedMessage = widget.initialTextPayload!;
      _timestamp = _formatCurrentTime();
    }

    // Register custom broadcast receiver
    _broadcastSubscription = BroadcastManager.instance.customBroadcastStream
        .listen((message) {
          if (mounted) {
            setState(() {
              _receivedMessage = message;
              _timestamp = _formatCurrentTime();
            });
          }
        });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _broadcastSubscription
        ?.cancel(); // Unregister broadcast receiver on destroy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 3: Custom Broadcast Receiver'),
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
                        color: Colors.green.withValues(alpha: 0.15),
                        shape: BoxShape.rectangle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Custom Broadcast Received!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The broadcast receiver in Activity 3 successfully captured the text payload from Activity 2.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.message,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'BROADCAST PAYLOAD:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (_timestamp.isNotEmpty)
                                Text(
                                  _timestamp,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _receivedMessage,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text('Return to Home Activity'),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeActivity(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
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
