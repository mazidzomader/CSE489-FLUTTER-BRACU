import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// ===========================================================================
/// BROADCAST RECEIVER SERVICE & STATE MANAGEMENT
/// Emulates Android's LocalBroadcastManager and System Battery Broadcasts
/// following Android Jetpack / reactive stream design philosophy.
/// ===========================================================================
class BroadcastManager {
  BroadcastManager._privateConstructor() {
    _initBatterySimulation();
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

  // 2. System Battery Notification Receiver Stream (`StreamController.broadcast`)
  final StreamController<int> _batteryBroadcastController =
      StreamController<int>.broadcast();
  Stream<int> get batteryBroadcastStream => _batteryBroadcastController.stream;

  int _currentBatteryLevel = 85;
  Timer? _batterySimulationTimer;

  void _initBatterySimulation() {
    // Emulate system battery percentage broadcast updates periodically
    _batterySimulationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      // Simulate slight battery level adjustments or user testing
      _batteryBroadcastController.add(_currentBatteryLevel);
    });
  }

  void dispose() {
    _batterySimulationTimer?.cancel();
    _customBroadcastController.close();
    _batteryBroadcastController.close();
  }

  /// Helper to trigger/simulate manual battery broadcast
  void simulateBatteryBroadcast(int newLevel) {
    _currentBatteryLevel = newLevel.clamp(0, 100);
    _batteryBroadcastController.add(_currentBatteryLevel);
  }

  int get currentBatteryLevel => _currentBatteryLevel;
}

/// ===========================================================================
/// MAIN APPLICATION ENTRY POINT & THEME (Android Jetpack M3 Design)
/// ===========================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Broadcast Receiver & Drawer Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeActivity(),
    );
  }
}

/// ===========================================================================
/// SHARED NAVIGATION DRAWER WIDGET
/// Implements Navigation Drawer with menu item: "A. Broadcast Receiver"
/// ===========================================================================
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.android, size: 40, color: Colors.blue.shade800),
            ),
            accountName: const Text(
              'Android Jetpack Practice',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('Fragment & Navigation Drawer Lab'),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.blueGrey),
            title: const Text('Home Activity', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeActivity()),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DRAWER MENU',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cell_tower, color: Color(0xFF1E88E5)),
            ),
            title: const Text(
              'A. Broadcast Receiver',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Select custom vs battery broadcast'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BroadcastReceiverSelectionActivity(),
                ),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pinch, color: Colors.purple),
            ),
            title: const Text(
              'B. Image Scale (Pinch)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Load internet image & zoom gesture'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImageScaleActivity()),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.video_library, color: Colors.red),
            ),
            title: const Text(
              'C. Video Player',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Play one video within app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoPlayerActivity()),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.audiotrack, color: Colors.green),
            ),
            title: const Text(
              'D. Audio Player',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Play one audio within app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioPlayerActivity()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// HOME ACTIVITY
/// Landing screen with instructions & easy drawer access.
/// ===========================================================================
class HomeActivity extends StatelessWidget {
  const HomeActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android Lab: Drawer & Broadcasts')),
      drawer: const AppNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Lab Exercise Flow',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This Flutter application demonstrates all 4 lab assignments (Drawer, Image Scale, Video, Audio):\n',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    _buildStepItem(
                      'A',
                      'Broadcast Receiver: Select custom vs battery broadcast via Spinner.',
                    ),
                    _buildStepItem(
                      'B',
                      'Image Scale: Load internet image and zoom with pinch gesture.',
                    ),
                    _buildStepItem(
                      'C',
                      'Video Player: Play video with interactive timeline and controls.',
                    ),
                    _buildStepItem(
                      'D',
                      'Audio Player: Play audio with equalizer visualizer and volume bar.',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick Launch Activities:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildLaunchButton(
                          context,
                          'A. Broadcasts',
                          Icons.cell_tower,
                          const Color(0xFF1E88E5),
                          const BroadcastReceiverSelectionActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'B. Image Scale',
                          Icons.pinch,
                          Colors.purple,
                          const ImageScaleActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'C. Video Player',
                          Icons.video_library,
                          Colors.red,
                          const VideoPlayerActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'D. Audio Player',
                          Icons.audiotrack,
                          Colors.green,
                          const AudioPlayerActivity(),
                        ),
                      ],
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

  Widget _buildStepItem(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              step,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget targetActivity,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetActivity),
        );
      },
    );
  }
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(12),
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
                                  Text(
                                    option.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.podcasts),
                          label: const Text(
                            'Send Broadcast & Open Activity 3',
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
/// ACTIVITY 2 (OPTION 2): BATTERY BROADCAST RECEIVER (`BatteryNotificationReceiverActivity`)
/// Receives battery percentage broadcast and displays real-time status.
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                        shape: BoxShape.circle,
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
                      'Listening to battery percentage broadcast notifications...',
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Simulate System Battery Broadcast:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBatterySimButton(15, '15% (Low)'),
                        _buildBatterySimButton(55, '55% (Mid)'),
                        _buildBatterySimButton(95, '95% (Full)'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // As per specification: "If the user selects the second option in the first activity then do nothing here [in Third Activity]."
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF1E88E5),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Note: Per lab specification, Option 2 (Battery Receiver) completes here. Activity 3 does nothing for this option.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildBatterySimButton(int level, String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: _getBatteryColor(level),
        side: BorderSide(color: _getBatteryColor(level)),
      ),
      onPressed: () {
        BroadcastManager.instance.simulateBatteryBroadcast(level);
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                              const Spacer(),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

/// ===========================================================================
/// ACTIVITY B: IMAGE SCALE ACTIVITY (`ImageScaleActivity`)
/// Loads an image from the internet and scales it with a pinch gesture.
/// ===========================================================================
class ImageScaleActivity extends StatefulWidget {
  const ImageScaleActivity({super.key});

  @override
  State<ImageScaleActivity> createState() => _ImageScaleActivityState();
}

class _ImageScaleActivityState extends State<ImageScaleActivity> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _adjustZoom(double factor) {
    setState(() {
      final newScale = (_currentScale * factor).clamp(0.5, 5.0);
      _transformationController.value = Matrix4.diagonal3Values(
        newScale,
        newScale,
        1.0,
      );
      _currentScale = newScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B. Image Scale (Pinch Gesture)'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Zoom',
            onPressed: _resetZoom,
          ),
        ],
      ),
      body: Column(
        children: [
          // Zoom Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.purple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pinch, color: Colors.purple, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Pinch-to-Zoom or use controls:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_currentScale * 100).round()}% Zoom',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Image Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              child: Center(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 5.0,
                  onInteractionUpdate: (details) {
                    setState(() {
                      _currentScale = _transformationController.value
                          .getMaxScaleOnAxis();
                    });
                  },
                  child: Image.network(
                    'https://picsum.photos/id/1018/1200/800',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading Internet Image...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Could not fetch image from internet.\nDisplaying local high-res fallback pattern for zoom practice:',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 300,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.purple,
                                      Colors.blue,
                                      Colors.orange,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Pinch Me to Scale!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Zoom Control Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                  ),
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Zoom Out (-25%)'),
                  onPressed: () => _adjustZoom(0.8),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Reset (100%)'),
                  onPressed: _resetZoom,
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                  ),
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Zoom In (+25%)'),
                  onPressed: () => _adjustZoom(1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// ACTIVITY C: VIDEO PLAYER ACTIVITY (`VideoPlayerActivity`)
/// Plays one video within app (media player interface with full controls).
/// ===========================================================================
class VideoPlayerActivity extends StatefulWidget {
  const VideoPlayerActivity({super.key});

  @override
  State<VideoPlayerActivity> createState() => _VideoPlayerActivityState();
}

class _VideoPlayerActivityState extends State<VideoPlayerActivity> {
  bool _isPlaying = false;
  double _currentSecond = 15.0;
  final double _totalSeconds = 225.0; // 03:45 total duration
  double _playbackSpeed = 1.0;
  double _volume = 0.8;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 1000), (
          timer,
        ) {
          if (mounted && _isPlaying) {
            setState(() {
              _currentSecond += _playbackSpeed;
              if (_currentSecond >= _totalSeconds) {
                _currentSecond = 0.0;
                _isPlaying = false;
                timer.cancel();
              }
            });
          }
        });
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _seek(double second) {
    setState(() {
      _currentSecond = second.clamp(0.0, _totalSeconds);
    });
  }

  String _formatTime(double totalSecs) {
    int mins = totalSecs.toInt() ~/ 60;
    int secs = totalSecs.toInt() % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player (Media Player)'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Player Viewport
              Card(
                elevation: 6,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Video Display Frame (Simulated High-Definition Video Stream)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isPlaying
                                ? [
                                    Colors.red.shade900,
                                    Colors.black87,
                                    Colors.blueGrey.shade900,
                                  ]
                                : [
                                    Colors.black87,
                                    Colors.grey.shade900,
                                    Colors.black87,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated Visual Content
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isPlaying
                                        ? Icons.movie_creation
                                        : Icons.play_circle_outline,
                                    size: 72,
                                    color: Colors.white.withValues(
                                      alpha: _isPlaying ? 0.9 : 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isPlaying
                                        ? 'Playing Stream: BigBuckBunny_1080p.mp4'
                                        : 'Video Paused',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Resolution: 1920x1080 • Codec: H.264 • Speed: ${_playbackSpeed}x',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Top Status Overlay
                            Positioned(
                              top: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.live_tv,
                                          color: Colors.redAccent,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'ONLINE STREAM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _formatTime(_currentSecond),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Media Player Controls Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.grey.shade900,
                      child: Column(
                        children: [
                          // Seek Timeline Slider
                          Row(
                            children: [
                              Text(
                                _formatTime(_currentSecond),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.redAccent,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.white,
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _currentSecond.clamp(
                                      0.0,
                                      _totalSeconds,
                                    ),
                                    max: _totalSeconds,
                                    onChanged: _seek,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(_totalSeconds),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Control Buttons & Settings (Responsive stacked layout)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Rewind 10s',
                                    onPressed: () => _seek(_currentSecond - 10),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      tooltip: _isPlaying ? 'Pause' : 'Play',
                                      onPressed: _togglePlayPause,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Forward 10s',
                                    onPressed: () => _seek(_currentSecond + 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Playback Speed Selector
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<double>(
                                        value: _playbackSpeed,
                                        dropdownColor: Colors.grey.shade800,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        icon: const Icon(
                                          Icons.speed,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        items: [0.5, 1.0, 1.25, 1.5, 2.0].map((
                                          speed,
                                        ) {
                                          return DropdownMenuItem<double>(
                                            value: speed,
                                            child: Text('${speed}x Speed'),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _playbackSpeed = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  // Volume Control
                                  Row(
                                    children: [
                                      Icon(
                                        _volume == 0
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: Colors.white70,
                                            thumbColor: Colors.white,
                                            trackHeight: 3,
                                          ),
                                          child: Slider(
                                            value: _volume,
                                            onChanged: (v) =>
                                                setState(() => _volume = v),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Video Player Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This screen demonstrates a full-featured video playback interface with seeking timeline, playback speed controls, and interactive player events.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// ACTIVITY D: AUDIO PLAYER ACTIVITY (`AudioPlayerActivity`)
/// Plays one audio within app (media player with visualizer & timeline).
/// ===========================================================================
class AudioPlayerActivity extends StatefulWidget {
  const AudioPlayerActivity({super.key});

  @override
  State<AudioPlayerActivity> createState() => _AudioPlayerActivityState();
}

class _AudioPlayerActivityState extends State<AudioPlayerActivity> {
  bool _isPlaying = false;
  double _currentSecond = 45.0;
  final double _totalSeconds = 260.0; // 04:20 total duration
  double _volume = 0.85;
  Timer? _audioTimer;

  @override
  void dispose() {
    _audioTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _audioTimer = Timer.periodic(const Duration(milliseconds: 1000), (
          timer,
        ) {
          if (mounted && _isPlaying) {
            setState(() {
              _currentSecond += 1.0;
              if (_currentSecond >= _totalSeconds) {
                _currentSecond = 0.0;
                _isPlaying = false;
                timer.cancel();
              }
            });
          }
        });
      } else {
        _audioTimer?.cancel();
      }
    });
  }

  String _formatTime(double totalSecs) {
    int mins = totalSecs.toInt() ~/ 60;
    int secs = totalSecs.toInt() % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildEqualizerBar(int index, double heightFactor) {
    double barHeight = _isPlaying
        ? (20 + ((index * 13 + (_currentSecond * 7).toInt()) % 40)).toDouble()
        : 8.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 6,
      height: barHeight,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _isPlaying ? Colors.greenAccent : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D. Audio Player (Media Player)'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Album Cover Art
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            'https://picsum.photos/id/1025/400/400',
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.green.shade900,
                                child: const Center(
                                  child: Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_isPlaying)
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    12,
                                    (index) => _buildEqualizerBar(index, 1.0),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Android Jetpack Audio Stream',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flutter Media Engine • Track #1 of 4',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 28),
                    // Audio Scrubbing Timeline
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green.shade600,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: Colors.green.shade700,
                          ),
                          child: Slider(
                            value: _currentSecond.clamp(0.0, _totalSeconds),
                            max: _totalSeconds,
                            onChanged: (val) =>
                                setState(() => _currentSecond = val),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_currentSecond),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _formatTime(_totalSeconds),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Playback Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          color: Colors.grey.shade700,
                          onPressed: () => setState(() => _currentSecond = 0),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          color: Colors.grey.shade700,
                          onPressed: () =>
                              setState(() => _currentSecond = _totalSeconds),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Volume Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _volume == 0 ? Icons.volume_off : Icons.volume_up,
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.green.shade600,
                              thumbColor: Colors.green.shade700,
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _volume,
                              onChanged: (v) => setState(() => _volume = v),
                            ),
                          ),
                        ),
                        Text(
                          '${(_volume * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
