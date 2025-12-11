import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';

class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends ConsumerState<WelcomeOnboardingScreen> {
  final PageController _controller = PageController();
  int _step = 0;

  final _usernameController = TextEditingController();
  bool _savingUsername = false;
  bool _savingAvatar = false;
  bool _requestingLocation = false;

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (_usernameController.text.trim().isEmpty) return;
    setState(() => _savingUsername = true);
    try {
      final profile = ref.read(profileControllerProvider).value;
      final repo = ref.read(profileRepositoryProvider);
      if (profile == null) {
        // We need the current user id from Supabase
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        if (supabaseUser == null) return;
        final newProfile = Profile(
          id: supabaseUser.id,
          username: _usernameController.text.trim(),
          fullName: null,
          avatarUrl: null,
          bannerUrl: null,
          bio: null,
          website: null,
          role: 'free',
          credits: 0,
          completedWelcome: false,
        );
        await repo.upsertProfile(newProfile);
      } else {
        final updated = profile.copyWith(
          username: _usernameController.text.trim(),
        );
        await repo.upsertProfile(updated);
      }
      // Refresh the cached profile for future reads
      ref.invalidate(profileControllerProvider);
      _goToStep(1);
    } finally {
      if (mounted) setState(() => _savingUsername = false);
    }
  }

  void _goToStep(int index) {
    setState(() => _step = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeWelcomeAndGoHome() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      final repo = ref.read(profileRepositoryProvider);
      final profile = ref.read(profileControllerProvider).value;

      final updated = (profile ?? Profile(id: supabaseUser.id)).copyWith(
        completedWelcome: true,
      );

      await repo.upsertProfile(updated);
      ref.invalidate(profileControllerProvider);
    }

    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _requestLocation() async {
    setState(() => _requestingLocation = true);
    try {
      await Geolocator.requestPermission();
      // We are not yet storing location; just requesting permission.
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
      if (mounted) {
        await _completeWelcomeAndGoHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final existingUsername = profileAsync.value?.username;

    if (existingUsername != null && _usernameController.text.isEmpty) {
      _usernameController.text = existingUsername;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _UsernameStep(
              controller: _usernameController,
              saving: _savingUsername,
              onNext: _saveUsername,
            ),
            _AvatarStep(
              saving: _savingAvatar,
              onSkip: () => _goToStep(2),
              onDone: () => _goToStep(2),
            ),
            _LocationStep(
              requesting: _requestingLocation,
              onAllow: _requestLocation,
              onSkip: _completeWelcomeAndGoHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsernameStep extends StatelessWidget {
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onNext;

  const _UsernameStep({
    required this.controller,
    required this.saving,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            "Welcome to Who's Got What!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('What should we call you?'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'your_handle',
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : onNext,
              child: saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Next'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AvatarStep extends StatelessWidget {
  final bool saving;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  const _AvatarStep({
    required this.saving,
    required this.onSkip,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    // For now, reuse the Settings screen for avatar editing; user can skip here.
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Add some style to your account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('You can add a profile image now, or skip and do this later in Settings.'),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: onSkip,
                child: const Text('Skip'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: saving ? null : onDone,
                child: const Text('Continue'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  final bool requesting;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const _LocationStep({
    required this.requesting,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            "Allow location access",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "In order to show Who's Got What in your area, we need some permissions.",
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: requesting ? null : onSkip,
                child: const Text('Maybe later'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: requesting ? null : onAllow,
                child: requesting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Allow location'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
