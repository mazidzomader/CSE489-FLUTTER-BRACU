import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';

/// ===========================================================================
/// ACTIVITY C: VIDEO PLAYER ACTIVITY (`VideoPlayerActivity`)
/// Plays one video within app (media player interface with full controls).
/// Uses `package:video_player` to stream local asset `assets/video.mp4`.
/// ===========================================================================
class VideoPlayerActivity extends StatefulWidget {
  const VideoPlayerActivity({super.key});

  @override
  State<VideoPlayerActivity> createState() => _VideoPlayerActivityState();
}

class _VideoPlayerActivityState extends State<VideoPlayerActivity>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  void _initializePlayer() {
    setState(() {
      _isInitialized = false;
      _errorMessage = null;
    });

    _controller = VideoPlayerController.asset(
      'assets/video.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            _controller.setVolume(_volume);
            _controller.setLooping(true);
            setState(() {
              _isInitialized = true;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
            });
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInitialized) {
      _controller.pause();
    }
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.setVolume(_volume);
      _controller.play();
    }
  }

  void _seekRelative(int seconds) {
    if (!_isInitialized) return;
    final current = _controller.value.position;
    final target = current + Duration(seconds: seconds);
    final total = _controller.value.duration;
    if (target < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (target > total) {
      _controller.seekTo(total);
    } else {
      _controller.seekTo(target);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player (Media Player)'),
        backgroundColor: Colors.red.shade700,
      ),
      drawer: const AppNavigationDrawer(),
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                margin: EdgeInsets.zero,
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final bool isPlaying = value.isPlaying;
                    final Duration currentPos = _isInitialized
                        ? value.position
                        : Duration.zero;
                    final Duration totalDur = _isInitialized
                        ? value.duration
                        : Duration.zero;
                    final double currentSecs =
                        currentPos.inMilliseconds / 1000.0;
                    final double totalSecs = totalDur.inMilliseconds / 1000.0;
                    final bool hasError = _errorMessage != null || value.hasError;

                    return Column(
                      children: [
                        // Video Display Frame (`VideoPlayer`)
                        AspectRatio(
                          aspectRatio: _isInitialized && value.aspectRatio > 0
                              ? value.aspectRatio
                              : 16 / 9,
                          child: Container(
                            color: Colors.black,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_isInitialized && !hasError)
                                  VideoPlayer(_controller)
                                else if (hasError)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.redAccent,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Unable to play assets/video.mp4\n${_errorMessage ?? value.errorDescription}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Note: If you just added the asset while the app was running,\nplease STOP and RE-RUN the app to bundle it into the APK.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            icon: const Icon(
                                              Icons.refresh,
                                              size: 18,
                                            ),
                                            label: const Text('Retry Loading'),
                                            onPressed: _initializePlayer,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading assets/video.mp4...',
                                          style: TextStyle(
                                            color: Colors.white70,
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
                                          borderRadius: BorderRadius.zero,
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
                                              'ASSET VIDEO',
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
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        child: Text(
                                          _formatDuration(currentPos),
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
                                    _formatDuration(currentPos),
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
                                        value: currentSecs.clamp(
                                          0.0,
                                          totalSecs > 0 ? totalSecs : 1.0,
                                        ),
                                        max: totalSecs > 0 ? totalSecs : 1.0,
                                        onChanged: (val) {
                                          if (_isInitialized) {
                                            _controller.seekTo(
                                              Duration(
                                                milliseconds:
                                                    (val * 1000).toInt(),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(totalDur),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // Control Buttons & Settings
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
                                        onPressed: () => _seekRelative(-10),
                                      ),
                                      Container(
                                        margin: EdgeInsets.zero,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          tooltip:
                                              isPlaying ? 'Pause' : 'Play',
                                          onPressed: _togglePlayPause,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.forward_10,
                                          color: Colors.white,
                                        ),
                                        tooltip: 'Forward 10s',
                                        onPressed: () => _seekRelative(10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      // Playback Speed Selector
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius: BorderRadius.zero,
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
                                            items: [0.5, 1.0, 1.25, 1.5, 2.0]
                                                .map((speed) {
                                                  return DropdownMenuItem<
                                                    double
                                                  >(
                                                    value: speed,
                                                    child: Text(
                                                      '${speed}x Speed',
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null &&
                                                  _isInitialized) {
                                                _controller.setPlaybackSpeed(
                                                  val,
                                                );
                                                setState(
                                                  () => _playbackSpeed = val,
                                                );
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
                                              data: SliderTheme.of(
                                                context,
                                              ).copyWith(
                                                activeTrackColor:
                                                    Colors.white70,
                                                thumbColor: Colors.white,
                                                trackHeight: 3,
                                              ),
                                              child: Slider(
                                                value: _volume,
                                                onChanged: (v) {
                                                  if (_isInitialized) {
                                                    _controller.setVolume(v);
                                                    setState(() => _volume = v);
                                                  }
                                                },
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
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Video Player Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Playing local video file from assets/video.mp4 using the official video_player plugin with full timeline seeking, volume slider, and speed control.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
