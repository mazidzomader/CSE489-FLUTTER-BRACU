import 'package:flutter/material.dart';
import 'main.dart';

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
        title: const Text('Image Scale (Pinch Gesture)'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Zoom',
            onPressed: _resetZoom,
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
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
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.zero,
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
                    'https://i.imgflip.com/9eg2ej.jpg',
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
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple,
                                      Colors.blue,
                                      Colors.orange,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.zero,
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
