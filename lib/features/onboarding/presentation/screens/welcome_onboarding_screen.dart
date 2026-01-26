import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';

class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState
    extends ConsumerState<WelcomeOnboardingScreen> {
  final PageController _controller = PageController();
  int _step = 0;

  final _usernameController = TextEditingController();
  bool _savingUsername = false;
  bool _savingAvatar = false;
  bool _requestingLocation = false;
  File? _avatarFile;

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
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        if (supabaseUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Error: No authenticated user found. Please try logging in again.',
                ),
              ),
            );
          }
          return;
        }
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
      ref.invalidate(profileControllerProvider);
      _goToStep(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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

  void _goBack() {
    if (_step > 0) {
      _goToStep(_step - 1);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _avatarFile = File(pickedFile.path));
    }
  }

  Future<void> _saveAvatarAndContinue() async {
    if (_avatarFile == null) {
      _goToStep(2);
      return;
    }

    setState(() => _savingAvatar = true);
    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) return;

      final fileExt = _avatarFile!.path.split('.').last;
      final fileName =
          '${supabaseUser.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      try {
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(
              fileName,
              _avatarFile!,
              fileOptions: const FileOptions(upsert: true),
            );

        final imageUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);

        final repo = ref.read(profileRepositoryProvider);
        final profile = ref.read(profileControllerProvider).value;
        if (profile != null) {
          final updated = profile.copyWith(avatarUrl: imageUrl);
          await repo.upsertProfile(updated);
          ref.invalidate(profileControllerProvider);
        }
      } catch (storageError) {
        debugPrint('Storage error (might be missing bucket): $storageError');
      }

      _goToStep(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving avatar: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingAvatar = false);
    }
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
    context.go('/subscription');
  }

  Future<void> _requestLocation() async {
    setState(() => _requestingLocation = true);
    try {
      await Geolocator.requestPermission();
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
      if (mounted) {
        await _completeWelcomeAndGoHome();
      }
    }
  }

  Future<void> _saveGoal(String goal) async {
    setState(
      () => _savingUsername = true,
    ); // Reuse saving state for simplicity or add new one
    try {
      final profile = ref.read(profileControllerProvider).value;
      final repo = ref.read(profileRepositoryProvider);
      if (profile != null) {
        final updated = profile.copyWith(onboardingGoal: goal);
        await repo.upsertProfile(updated);
        ref.invalidate(profileControllerProvider);
      }
      _goToStep(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingUsername = false);
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
      appBar: AppBar(title: const Text("Welcome")),
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
            _GoalStep(onSelected: _saveGoal, onBack: _goBack),
            _AvatarStep(
              saving: _savingAvatar,
              selectedImage: _avatarFile,
              onPickImage: _pickImage,
              onBack: _goBack,
              onSkip: () => _goToStep(3),
              onDone: _saveAvatarAndContinue,
            ),
            _LocationStep(
              requesting: _requestingLocation,
              onBack: _goBack,
              onAllow: _requestLocation,
              onSkip: _completeWelcomeAndGoHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final Function(String) onSelected;
  final VoidCallback onBack;

  const _GoalStep({required this.onSelected, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 16),
          const Text(
            "What brings you here?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Tell us a bit about why you're joining Streetside Local.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _GoalOption(
            icon: Icons.search,
            title: "I'm looking for local adventure",
            subtitle: "Find events, workshops, and more nearby.",
            onTap: () => onSelected('find'),
          ),
          const SizedBox(height: 16),
          _GoalOption(
            icon: Icons.event,
            title: "I want to share my events",
            subtitle: "Post and manage your own happenings.",
            onTap: () => onSelected('share'),
          ),
          const SizedBox(height: 16),
          _GoalOption(
            icon: Icons.business,
            title: "I'm a business looking for growth",
            subtitle: "Reach more locals and build your brand.",
            onTap: () => onSelected('business'),
          ),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GoalOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
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
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/onboarding_username_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/icons/all-icons/NewAppIcons/appstore.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Welcome to Streetside Local!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
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
                  child:
                      saving
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
        ),
      ],
    );
  }
}

class _AvatarStep extends StatelessWidget {
  final bool saving;
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  const _AvatarStep({
    required this.saving,
    this.selectedImage,
    required this.onPickImage,
    required this.onBack,
    required this.onSkip,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/splash_community.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add some style to your account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            selectedImage != null
                                ? FileImage(selectedImage!)
                                : null,
                        child:
                            selectedImage == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('Tap to choose a photo')),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : onDone,
                  child:
                      saving
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            selectedImage != null ? 'Continue' : 'Skip for now',
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final bool requesting;
  final VoidCallback onBack;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const _LocationStep({
    required this.requesting,
    required this.onBack,
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 16),
          const Text(
            "Allow location access",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'In order to show Streetside Local in your area, we need some permissions.',
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
                child:
                    requesting
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
