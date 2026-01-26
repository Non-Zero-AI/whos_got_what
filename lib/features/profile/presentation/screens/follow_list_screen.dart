
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/events/presentation/screens/home_screen.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class FollowListScreen extends ConsumerWidget {
  final String userId;
  final bool showFollowers;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider(userId));
    final profilesAsync = showFollowers
        ? ref.watch(followersProvider(userId))
        : ref.watch(followingProvider(userId));

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: profileAsync.when(
            data: (p) => Text(
              showFollowers ? 'Followers of ${p?.displayName}' : 'Following',
              style: AppTextStyles.titleMedium(context),
            ),
            loading: () => const Text('Loading...'),
            error: (_, __) => Text(showFollowers ? 'Followers' : 'Following'),
          ),
          centerTitle: true,
        ),
        body: profilesAsync.when(
          data: (profiles) {
            if (profiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      showFollowers ? Icons.group_outlined : Icons.person_add_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      showFollowers ? 'No followers yet.' : 'Not following anyone yet.',
                      style: AppTextStyles.body(context).copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final p = profiles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: UserMiniCard(profile: p),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
