import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage;
  bool _isFading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final skipVideo =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (skipVideo) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _navigateToNext();
      return;
    }

    debugPrint(
      'Initializing video: assets/video/Splash_Screen_Animation_Generation.mp4',
    );
    _controller = VideoPlayerController.asset(
      'assets/video/Splash_Screen_Animation_Generation.mp4',
    );

    try {
      debugPrint('Calling video controller initialize...');
      await _controller!.initialize();
      debugPrint(
        'Video initialized successfully. Duration: ${_controller!.value.duration}',
      );

      _controller!.setLooping(false);
      _controller!.addListener(_checkVideoPosition);

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

  void _checkVideoPosition() {
    final controller = _controller;
    if (controller == null) return;

    // Check if video has reached 5 seconds
    if (controller.value.position >= const Duration(seconds: 5)) {
      if (!_isFading) {
        _isFading = true;
        controller.pause();
        _startFadeToBlack();
      }
    }
  }

  void _startFadeToBlack() {
    _fadeController.forward().then((_) {
      // After fade completes, navigate
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    _controller?.removeListener(_checkVideoPosition);
    if (mounted) {
      context.go('/intro');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // True black background
          Container(color: Colors.black),

          // Header, subheader, and animation grouped together in center
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header and subheader grouped together
                Text(
                  "Who's Got What",
                  style: AppTextStyles.headlinePrimary(
                    context,
                  ).copyWith(color: Colors.white, fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Partner for Local Adventure.',
                  style: AppTextStyles.bodyEmphasis(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 48),
                // Video player - 600x600 container
                if (_initialized &&
                    _controller != null &&
                    _controller!.value.isInitialized)
                  SizedBox(
                    width: 600,
                    height: 600,
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),

          // Fade to black overlay
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.black.withValues(alpha: _fadeAnimation.value),
              );
            },
          ),
        ],
      ),
    );
  }
}
