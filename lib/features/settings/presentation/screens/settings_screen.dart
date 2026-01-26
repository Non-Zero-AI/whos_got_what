import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/core/data/mock_data_seeder.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_text_field.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/providers/dev_mode_provider.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/notifications/data/notification_repository.dart';
import 'package:whos_got_what/features/notifications/data/notification_providers.dart';

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
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
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
      final path =
          isAvatar
              ? 'avatars/${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt'
              : 'banners/${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('profile-media').uploadBinary(path, bytes);

      final publicUrl = supabase.storage
          .from('profile-media')
          .getPublicUrl(path);

      setState(() {
        if (isAvatar) {
          _avatarUrlController.text = publicUrl;
        } else {
          _bannerUrlController.text = publicUrl;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
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

    final current = existing ?? Profile(id: user.id, role: 'free', credits: 0);

    final updated = current.copyWith(
      username:
          _usernameController.text.trim().isEmpty
              ? null
              : _usernameController.text.trim(),
      fullName:
          _fullNameController.text.trim().isEmpty
              ? null
              : _fullNameController.text.trim(),
      bio:
          _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
      website:
          _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
      avatarUrl:
          _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
      bannerUrl:
          _bannerUrlController.text.trim().isEmpty
              ? null
              : _bannerUrlController.text.trim(),
    );

    await controller.updateProfile(updated);

    // Invalidate the provider to ensure the profile is refetched and UI is updated
    ref.invalidate(profileControllerProvider);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (!mounted) return;

    // Go back to the intro carousel; router redirect will handle auth state.
    context.go('/intro');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account?'),
            content: const Text(
              'This is permanent. All your events and data will be deleted forever.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authRepositoryProvider).deleteAccount();
        if (mounted) {
          context.go('/intro');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      }
    }
  }

  Widget _buildNotificationSettings() {
    final notificationPrefs = ref.watch(notificationPreferencesProvider);
    final systemNotificationsEnabled = ref.watch(
      systemNotificationsEnabledProvider,
    );

    return notificationPrefs.when(
      data: (prefs) {
        final systemEnabled = systemNotificationsEnabled.value ?? true;

        return Column(
          children: [
            NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(24),
              child: SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: Text(
                  systemEnabled
                      ? 'Get notified when profiles you subscribe to post new events'
                      : 'Enable notifications in system settings first',
                ),
                value: prefs.pushEnabled && systemEnabled,
                onChanged:
                    systemEnabled
                        ? (value) {
                          ref
                              .read(notificationControllerProvider.notifier)
                              .setPushNotificationsEnabled(value);
                        }
                        : null,
              ),
            ),
            if (!systemEnabled) ...[
              const SizedBox(height: 12),
              NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  // Open app settings
                  // Note: This requires app_settings package or manual implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enable notifications in your device settings',
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Open System Notification Settings'),
                    ),
                    const Icon(Icons.open_in_new, size: 18),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'When enabled, you\'ll receive notifications when profiles you follow and subscribe to create new events.',
                style: AppTextStyles.captionMuted(context),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading preferences: $e'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final profileAsync = ref.watch(profileControllerProvider);

    _maybeInitFromProfile(profileAsync.value);

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: 'Theme', icon: Icons.palette_outlined),
            const SizedBox(height: 16),
            NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(24),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark themes'),
                value: themeState.mode == ThemeMode.dark,
                onChanged: (value) => themeNotifier.toggleTheme(value),
              ),
            ),
            const SizedBox(height: 32),

            // --- Notifications Section ---
            _SectionHeader(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
            ),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 32),

            // --- Development Section ---
            if (kDebugMode) ...[
              _SectionHeader(
                title: 'Development',
                icon: Icons.bug_report_outlined,
              ),
              const SizedBox(height: 16),
              NeumorphicContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(24),
                child: SwitchListTile(
                  title: const Text('Dev Mode (Bypass Subs)'),
                  value: ref.watch(devModeProvider),
                  onChanged:
                      (value) => ref.read(devModeProvider.notifier).toggle(),
                  secondary: const Icon(Icons.verified_user_outlined),
                ),
              ),
              const SizedBox(height: 12),
              NeumorphicContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  final seeder = MockDataService(
                    ref.read(supabaseClientProvider),
                  );
                  try {
                    await seeder.seedEvents();
                    ref.invalidate(eventsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mock events seeded!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to seed: $e')),
                      );
                    }
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined),
                    SizedBox(width: 12),
                    Text('Seed Mock Events'),
                    Spacer(),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            const Divider(height: 32),
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.push('/feedback'),
              child: const Row(
                children: [
                  Icon(Icons.feedback_outlined),
                  SizedBox(width: 12),
                  Text('Send Feedback'),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: _signOut,
            ),
            const Divider(height: 32),
            Text('Edit Profile', style: AppTextStyles.titleMedium(context)),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _usernameController,
              hintText: 'Enter username',
              labelText: 'Username',
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _fullNameController,
              hintText: 'Enter name',
              labelText: 'Business or Personal Name',
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _bioController,
              hintText: 'Enter bio',
              labelText: 'Bio',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _websiteController,
              hintText: 'Enter website URL',
              labelText: 'Website / Main link',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _avatarUrlController,
              hintText: 'Enter avatar URL',
              labelText: 'Avatar image URL',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed:
                    _isUploadingAvatar
                        ? null
                        : () => _pickAndUploadImage(isAvatar: true),
                icon:
                    _isUploadingAvatar
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.photo_library),
                label: const Text('Choose avatar from device'),
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _bannerUrlController,
              hintText: 'Enter banner URL',
              labelText: 'Banner image URL',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed:
                    _isUploadingBanner
                        ? null
                        : () => _pickAndUploadImage(isAvatar: false),
                icon:
                    _isUploadingBanner
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.photo_library),
                label: const Text('Choose banner from device'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    profileAsync.isLoading
                        ? null
                        : () => _saveProfile(profileAsync.value),
                icon: const Icon(Icons.save),
                label: Text(
                  'Save Profile',
                  style: AppTextStyles.labelPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Danger Zone',
              style: AppTextStyles.titleMedium(
                context,
              ).copyWith(color: Colors.red),
            ),
            const SizedBox(height: 12),
            NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(24),
              onTap: _deleteAccount,
              child: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    'Delete Account',
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
