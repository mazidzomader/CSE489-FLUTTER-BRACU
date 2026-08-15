import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landmarksAsync = ref.watch(mapLandmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Map',
            onPressed: () => ref.invalidate(mapLandmarksProvider),
          ),
        ],
      ),
      body: landmarksAsync.when(
        data: (landmarks) {
          if (landmarks.isEmpty) {
            return const Center(child: Text('No landmarks found.'));
          }

          final minScore =
              landmarks.map((l) => l.score).reduce((a, b) => a < b ? a : b);
          final maxScore =
              landmarks.map((l) => l.score).reduce((a, b) => a > b ? a : b);

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(23.6850, 90.3563), // Bangladesh center
              initialZoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.midterm_assignment',
              ),
              MarkerLayer(
                markers: landmarks.map((landmark) {
                  return Marker(
                    point: LatLng(landmark.lat, landmark.lon),
                    width: 44,
                    height: 52,
                    alignment: Alignment.topCenter,
                    child: _buildPointerWidget(
                      context,
                      landmark,
                      minScore,
                      maxScore,
                      ref,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading map data: $err')),
      ),
    );
  }

  /// Custom designed modern map pointer with score-based gradient
  Widget _buildPointerWidget(
    BuildContext context,
    LandmarkDto landmark,
    double minScore,
    double maxScore,
    WidgetRef ref,
  ) {
    final range = (maxScore - minScore).abs();
    final fraction =
        range == 0 ? 0.5 : ((landmark.score - minScore) / range).clamp(0.0, 1.0);

    Color scoreColor;
    if (fraction < 0.5) {
      scoreColor = Color.lerp(
        const Color(0xFFE53935), // Low: Red
        const Color(0xFFFFB300), // Mid: Amber
        fraction * 2,
      )!;
    } else {
      scoreColor = Color.lerp(
        const Color(0xFFFFB300), // Mid: Amber
        const Color(0xFF00C853), // High: Emerald Green
        (fraction - 0.5) * 2,
      )!;
    }

    final darkerShade = Color.lerp(scoreColor, Colors.black, 0.2)!;

    return GestureDetector(
      onTap: () => _showLandmarkDetails(context, landmark, ref),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular pin head
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scoreColor, darkerShade],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.place_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          // Pointer tip
          CustomPaint(
            size: const Size(10, 7),
            painter: _TrianglePainter(
              color: darkerShade,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showLandmarkDetails(
      BuildContext context, LandmarkDto landmark, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image
              if (landmark.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: landmark.image,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    memCacheHeight: 400,
                    placeholder: (ctx, url) => Container(
                      height: 170,
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (ctx, url, error) => Container(
                      height: 170,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Title
              Text(
                landmark.title,
                style: Theme.of(sheetContext)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Details
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'Score: ${landmark.score}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 16, color: Colors.blue.shade800),
                        const SizedBox(width: 4),
                        Text(
                          '${landmark.visitCount} visits',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    try {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Getting location...')),
                        );
                      }

                      bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        throw Exception('Location services are disabled.');
                      }

                      LocationPermission permission =
                          await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          throw Exception('Location permissions are denied');
                        }
                      }
                      if (permission == LocationPermission.deniedForever) {
                        throw Exception(
                            'Location permissions are permanently denied.');
                      }

                      Position? position =
                          await Geolocator.getLastKnownPosition();
                      position ??= await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(
                          accuracy: LocationAccuracy.high,
                          timeLimit: Duration(seconds: 10),
                        ),
                      );

                      await ref
                          .read(landmarkRepositoryProvider)
                          .visitLandmark(
                              landmark, position.latitude, position.longitude);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Visit started for "${landmark.title}"!'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                        // Jump to Activity Tab to watch the background progress
                        ref.read(bottomNavIndexProvider.notifier).state = 2;
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('OK'),
                              )
                            ],
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.directions_run),
                  label: const Text(
                    'Visit Landmark',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for the downward triangle / pointer tip of the pin
class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderColor != borderColor;
}
