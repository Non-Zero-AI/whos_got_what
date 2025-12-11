import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bannerUrlController = TextEditingController();
  bool _isUploadingAvatar = false;
  bool _isUploadingBanner = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _avatarUrlController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage({required bool isAvatar}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      if (isAvatar) {
        _isUploadingAvatar = true;
      } else {
        _isUploadingBanner = true;
      }
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('You must be signed in to upload images.');
      }

      final bytes = await picked.readAsBytes();
      final fileExt = picked.path.split('.').last;
      final path = isAvatar
          ? 'avatars/${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt'
          : 'banners/${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('profile-media').uploadBinary(path, bytes);

      final publicUrl = supabase.storage.from('profile-media').getPublicUrl(path);

      setState(() {
        if (isAvatar) {
          _avatarUrlController.text = publicUrl;
        } else {
          _bannerUrlController.text = publicUrl;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isAvatar) {
            _isUploadingAvatar = false;
          } else {
            _isUploadingBanner = false;
          }
        });
      }
    }
  }

  void _maybeInitFromProfile(Profile? profile) {
    if (profile == null) return;
    if (_usernameController.text.isEmpty) {
      _usernameController.text = profile.username ?? '';
      _fullNameController.text = profile.fullName ?? '';
      _bioController.text = profile.bio ?? '';
      _websiteController.text = profile.website ?? '';
      _avatarUrlController.text = profile.avatarUrl ?? '';
      _bannerUrlController.text = profile.bannerUrl ?? '';
    }
  }

  Future<void> _saveProfile(Profile? existing) async {
    final controller = ref.read(profileControllerProvider.notifier);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Create an account'),
              content: const Text(
                'You need a full account to update your profile. Sign up or sign in to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/auth');
                  },
                  child: const Text('Create account'),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    final current = existing ??
        Profile(
          id: user.id,
          role: 'free',
          credits: 0,
        );

    final updated = current.copyWith(
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim().isEmpty
          ? null
          : _avatarUrlController.text.trim(),
      bannerUrl: _bannerUrlController.text.trim().isEmpty
          ? null
          : _bannerUrlController.text.trim(),
    );

    await controller.updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final profileAsync = ref.watch(profileControllerProvider);

    _maybeInitFromProfile(profileAsync.value);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeState.mode == ThemeMode.dark,
            onChanged: (value) => themeNotifier.toggleTheme(value),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ColorOption(color: const Color(0xFF6200EE), selected: themeState.accentColor),
              _ColorOption(color: Colors.blue, selected: themeState.accentColor),
              _ColorOption(color: Colors.red, selected: themeState.accentColor),
              _ColorOption(color: Colors.green, selected: themeState.accentColor),
              _ColorOption(color: Colors.orange, selected: themeState.accentColor),
              _ColorOption(color: Colors.teal, selected: themeState.accentColor),
            ],
          ),
          const Divider(height: 32),
          const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'your_handle',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Business or Personal Name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Website / Main link',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avatarUrlController,
            decoration: const InputDecoration(
              labelText: 'Avatar image URL',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isUploadingAvatar
                  ? null
                  : () => _pickAndUploadImage(isAvatar: true),
              icon: _isUploadingAvatar
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library),
              label: const Text('Choose avatar from device'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bannerUrlController,
            decoration: const InputDecoration(
              labelText: 'Banner image URL',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isUploadingBanner
                  ? null
                  : () => _pickAndUploadImage(isAvatar: false),
              icon: _isUploadingBanner
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library),
              label: const Text('Choose banner from device'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: profileAsync.isLoading
                ? null
                : () => _saveProfile(profileAsync.value),
            icon: const Icon(Icons.save),
            label: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends ConsumerWidget {
  final Color color;
  final Color? selected;

  const _ColorOption({required this.color, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selected != null && color.value == selected!.value;
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setAccentColor(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              )
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
