import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final skipVideo = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (skipVideo) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _navigateToNext();
      return;
    }

    debugPrint('Initializing video: assets/video/Splash_Screen_Animation_Generation.mp4');
    _controller = VideoPlayerController.asset(
      'assets/video/Splash_Screen_Animation_Generation.mp4',
    );

    try {
      debugPrint('Calling video controller initialize...');
      await _controller!.initialize();
      debugPrint('Video initialized successfully. Duration: ${_controller!.value.duration}');
      
      _controller!.setLooping(false);
      _controller!.addListener(_checkVideoEnd);
      
      debugPrint('Starting video playback...');
      await _controller!.play();
      
      if (mounted) {
        setState(() {
          _initialized = true;
          _errorMessage = null;
        });
      }
      debugPrint('Video state updated, should be visible now');
    } catch (e, stackTrace) {
      debugPrint('Error initializing video: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load video: $e';
          _initialized = false;
        });
      }
      // Wait a bit then navigate
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateToNext();
      }
    }
  }

  void _checkVideoEnd() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.position >= controller.value.duration) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    _controller?.removeListener(_checkVideoEnd);
    if (mounted) {
      context.go('/intro');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg, // Match light theme background
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _controller != null && _controller!.value.isInitialized)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Loading video...',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _navigateToNext,
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
