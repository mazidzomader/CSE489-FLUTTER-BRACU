import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';

/// ===========================================================================
/// ACTIVITY D: AUDIO PLAYER ACTIVITY (`AudioPlayerActivity`)
/// Plays local asset `assets/audio.mp3` with basic media controls.
/// ===========================================================================
class AudioPlayerActivity extends StatefulWidget {
  const AudioPlayerActivity({super.key});

  @override
  State<AudioPlayerActivity> createState() => _AudioPlayerActivityState();
}

class _AudioPlayerActivityState extends State<AudioPlayerActivity> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to play/pause state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen for total duration once source is loaded
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    // Listen for current playback position (updates seek slider)
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _initSource();
  }

  Future<void> _initSource() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      // AssetSource internally prepends 'assets/' — so pass just 'audio.mp3'
      await _audioPlayer.setSource(AssetSource('audio.mp3'));
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isPlaying) {
      _audioPlayer.pause();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource('audio.mp3'));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final double currentSecs = _position.inMilliseconds / 1000.0;
    final double totalSecs = _duration.inMilliseconds / 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player (Media Player)'),
        backgroundColor: Colors.green.shade700,
      ),
      drawer: const AppNavigationDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error UI
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unable to play assets/audio.mp3\n$_errorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Note: If you just added audio.mp3 while the app was running, '
                              'please STOP and RE-RUN flutter run to package the asset.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                              onPressed: _initSource,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Album cover image
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.asset(
                        'assets/cover.jpg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
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
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Local Audio Asset Stream',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'assets/audio.mp3 • Flutter AudioEngine',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Seek Timeline Slider
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green.shade600,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: Colors.green.shade700,
                          ),
                          child: Slider(
                            value: currentSecs.clamp(
                              0.0,
                              totalSecs > 0 ? totalSecs : 1.0,
                            ),
                            max: totalSecs > 0 ? totalSecs : 1.0,
                            onChanged: (val) {
                              _audioPlayer.seek(
                                Duration(milliseconds: (val * 1000).toInt()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
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

                    // Playback Controls: Previous | Play/Pause | Next
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          color: Colors.grey.shade700,
                          onPressed: () => _audioPlayer.seek(Duration.zero),
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
                          onPressed: () => _audioPlayer.seek(_duration),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Volume Slider
                    Row(
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
                              onChanged: (v) {
                                _audioPlayer.setVolume(v);
                                setState(() => _volume = v);
                              },
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
