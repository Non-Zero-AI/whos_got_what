import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;

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

    _controller = VideoPlayerController.asset(
      'assets/video/App_Splash_Screen_Animation_Generation.mp4',
    );

    try {
      await _controller!.initialize();
      _controller!.addListener(_checkVideoEnd);
      await _controller!.play();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      _navigateToNext();
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
      backgroundColor: Colors.black, // or match app theme
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          
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
