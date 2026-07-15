import 'package:flutter/material.dart';
import 'broadcast_page.dart';
import 'image_scale_page.dart';
import 'video_player_page.dart';
import 'audio_player_page.dart';

void main() {
  runApp(const MyApp());
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
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
              ),
              child: const Icon(Icons.cell_tower, color: Color(0xFF1E88E5)),
            ),
            title: const Text(
              'Broadcast Receiver',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Select custom vs battery broadcast'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const BroadcastReceiverSelectionActivity(),
                ),
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
              ),
              child: const Icon(Icons.pinch, color: Colors.purple),
            ),
            title: const Text(
              'Image Scale (Pinch)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Load internet image & zoom gesture'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ImageScaleActivity()),
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
              ),
              child: const Icon(Icons.video_library, color: Colors.red),
            ),
            title: const Text(
              'Video Player',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Play one video within app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const VideoPlayerActivity()),
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
              ),
              child: const Icon(Icons.audiotrack, color: Colors.green),
            ),
            title: const Text(
              'Audio Player',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text('Play one audio within app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AudioPlayerActivity()),
                (route) => route.isFirst,
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
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
                      Icons.cell_tower,
                      const Color(0xFF1E88E5),
                      'Broadcast Receiver: Select custom vs battery broadcast via Spinner.',
                    ),
                    _buildStepItem(
                      Icons.pinch,
                      Colors.purple,
                      'Image Scale: Load internet image and zoom with pinch gesture.',
                    ),
                    _buildStepItem(
                      Icons.video_library,
                      Colors.red,
                      'Video Player: Play video with interactive timeline and controls.',
                    ),
                    _buildStepItem(
                      Icons.audiotrack,
                      Colors.green,
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
                          'Broadcasts',
                          Icons.cell_tower,
                          const Color(0xFF1E88E5),
                          const BroadcastReceiverSelectionActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'Image Scale',
                          Icons.pinch,
                          Colors.purple,
                          const ImageScaleActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'Video Player',
                          Icons.video_library,
                          Colors.red,
                          const VideoPlayerActivity(),
                        ),
                        _buildLaunchButton(
                          context,
                          'Audio Player',
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

  Widget _buildStepItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.rectangle,
            ),
            child: Icon(icon, size: 16, color: color),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => targetActivity),
          (route) => route.isFirst,
        );
      },
    );
  }
}
