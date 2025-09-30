import 'dart:io';
import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:locker_app/src/features/video_player/widgets/seek_bar.dart';
import 'package:locker_app/src/features/video_player/widgets/forward_skip_button.dart';
import 'package:locker_app/src/features/video_player/widgets/backward_skip_button.dart';

class VideoPlayerScreen extends StatefulWidget {
   final File file;
  const VideoPlayerScreen({super.key, required this.file});
 

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isLandscape = false;
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.addListener(() {
      setState(() {
        _position = _controller.value.position;
      });
      if (_controller.value.isPlaying && _controlsVisible) {
        _startHideControlsTimer();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    // Ensure the orientation is reset to portrait when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Show system overlays again
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_controller.value.isPlaying) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startHideControlsTimer();
    }
  }

  void _toggleLandscape() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows content to go behind the AppBar
      appBar: _controlsVisible ? AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isLandscape ? Icons.screen_rotation : Icons.screen_lock_portrait),
            onPressed: _toggleLandscape,
          ),
        ],
      ) : null,
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          onTap: _toggleControlsVisibility,
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black38, // Semi-transparent overlay for controls
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // AppBar is now part of the Scaffold, so remove it from here
                            const Spacer(),
                            Column(
                              children: [
                                // VideoProgressIndicator(_controller, allowScrubbing: true), // Removed as SeekBar is used
                                SeekBar(
                                  duration: _controller.value.duration,
                                  position: _position, // Use the state variable
                                  onChanged: (newPosition) {
                                    _controller.seekTo(newPosition);
                                  },
                                  onChangeEnd: (newPosition) {
                                    _controller.seekTo(newPosition);
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_controller.value.position.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                                        '${_controller.value.position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    BackwardSkipButton(
                                      onPressed: () {
                                        final newPosition = _controller.value.position - const Duration(seconds: 10);
                                        _controller.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                        });
                                      },
                                    ),
                                    ForwardSkipButton(
                                      onPressed: () {
                                        final newPosition = _controller.value.position + const Duration(seconds: 10);
                                        _controller.seekTo(newPosition > _controller.value.duration ? _controller.value.duration : newPosition);
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${_controller.value.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                                        '${_controller.value.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).paddingBottom(20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
