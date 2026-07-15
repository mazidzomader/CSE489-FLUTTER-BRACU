import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';

/// ===========================================================================
/// ACTIVITY D: AUDIO PLAYER ACTIVITY (`AudioPlayerActivity`)
/// Plays local asset `assets/audio.mp3` with embedded album cover & controls.
/// ===========================================================================
class AudioPlayerActivity extends StatefulWidget {
  const AudioPlayerActivity({super.key});

  @override
  State<AudioPlayerActivity> createState() => _AudioPlayerActivityState();
}

class _AudioPlayerActivityState extends State<AudioPlayerActivity>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  String? _errorMessage;
  Uint8List? _albumArtBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();

    // Configure AudioContext for optimal Android/iOS speaker playback & focus
    _audioPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
      ),
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _initSource();
  }

  /// Extracts embedded ID3v2 APIC album cover picture (`JPEG`/`PNG`) right from MP3 file.
  Uint8List? _extractAlbumArtFromBytes(Uint8List bytes) {
    try {
      int apicIndex = -1;
      for (int i = 0; i < bytes.length - 10 && i < 500000; i++) {
        if (bytes[i] == 0x41 &&
            bytes[i + 1] == 0x50 &&
            bytes[i + 2] == 0x49 &&
            bytes[i + 3] == 0x43) {
          // 'APIC'
          apicIndex = i;
          break;
        }
      }

      if (apicIndex != -1) {
        int soiIndex = -1;
        bool isJpeg = false;
        for (
          int j = apicIndex + 4;
          j < bytes.length - 4 && j < apicIndex + 200;
          j++
        ) {
          if (bytes[j] == 0xFF &&
              bytes[j + 1] == 0xD8 &&
              bytes[j + 2] == 0xFF) {
            soiIndex = j;
            isJpeg = true;
            break;
          } else if (bytes[j] == 0x89 &&
              bytes[j + 1] == 0x50 &&
              bytes[j + 2] == 0x4E &&
              bytes[j + 3] == 0x47) {
            soiIndex = j;
            isJpeg = false;
            break;
          }
        }

        if (soiIndex != -1) {
          if (isJpeg) {
            int eoiIndex = -1;
            for (
              int k = soiIndex + 2;
              k < bytes.length - 1 && k < soiIndex + 3000000;
              k++
            ) {
              if (bytes[k] == 0xFF && bytes[k + 1] == 0xD9) {
                eoiIndex = k + 2;
              }
            }
            if (eoiIndex != -1) {
              return bytes.sublist(soiIndex, eoiIndex);
            }
          } else {
            for (
              int k = soiIndex + 8;
              k < bytes.length - 8 && k < soiIndex + 3000000;
              k++
            ) {
              if (bytes[k] == 0x49 &&
                  bytes[k + 1] == 0x45 &&
                  bytes[k + 2] == 0x4E &&
                  bytes[k + 3] == 0x44) {
                return bytes.sublist(soiIndex, k + 8);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting album art: $e');
    }
    return null;
  }

  Future<void> _initSource() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      // Load cover art embedded inside ID3 tag of assets/audio.mp3
      try {
        final byteData = await rootBundle.load('assets/audio.mp3');
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        final extractedArt = _extractAlbumArtFromBytes(bytes);
        if (mounted) {
          setState(() {
            _albumArtBytes = extractedArt;
          });
        }
      } catch (artError) {
        debugPrint('Could not extract album art: $artError');
      }

      // Note: AssetSource automatically prefixes 'assets/' internally
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isPlaying) {
        _audioPlayer.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Widget _buildEqualizerBar(int index) {
    double barHeight = _isPlaying
        ? (20 + ((index * 13 + (_position.inMilliseconds / 80).toInt()) % 40))
              .toDouble()
        : 8.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 6,
      height: barHeight,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _isPlaying ? Colors.greenAccent : Colors.grey.shade700,
        borderRadius: BorderRadius.zero,
      ),
    );
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
                              'Note: If you just added audio.mp3 while the app was running, please STOP and RE-RUN flutter run to package the asset.',
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

                    // Album Cover Art (ID3v2 APIC Embedded Picture)
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.zero,
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
                          if (_albumArtBytes != null)
                            Image.memory(
                              _albumArtBytes!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/cover.jpg',
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 200,
                                  errorBuilder: (context, err, stack) => Container(
                                    color: Colors.green.shade900,
                                    child: const Center(
                                      child: Icon(
                                        Icons.music_note,
                                        size: 80,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Image.asset(
                              'assets/cover.jpg',
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, err, stack) => Container(
                                color: Colors.green.shade900,
                                child: const Center(
                                  child: Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  12,
                                  (index) => _buildEqualizerBar(index),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    // Playback Control Buttons
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
