import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/auth'),
            child: const Text('Sign In'),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final userEventsAsync = ref.watch(userEventsProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    final profile = profileAsync.value;
    final displayName =
        profile?.fullName ?? profile?.username ?? user.email?.split('@').first ?? 'User';
    final handle = profile?.username ?? user.email?.split('@').first;
    final isPaid = profile?.role == 'paid';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Profile'),
                pinned: false,
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.go('/profile/settings'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Banner + avatar + basic info
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: profile?.bannerUrl == null
                                  ? LinearGradient(
                                      colors: [
                                        theme.colorScheme.surfaceContainerHighest,
                                        theme.colorScheme.surface,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              image: profile?.bannerUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(profile!.bannerUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            top: 166,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: profile?.avatarUrl != null
                                      ? NetworkImage(profile!.avatarUrl!)
                                      : null,
                                  child: profile?.avatarUrl == null
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: AppTextStyles.titleLarge(context),
                                      ),
                                      if (handle != null && handle.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '@${handle.trim()}',
                                          style: AppTextStyles.captionMuted(context),
                                        ),
                                      ],
                                      if (isPaid) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              'Business Account',
                                              style: AppTextStyles.bodySmall(context),
                                            ),
                                            const SizedBox(width: 8),
                                            NeumorphicContainer(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Text(
                                                'PAID',
                                                style: AppTextStyles.labelSecondary(context).copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Social links & stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (profile?.website != null && profile!.website!.trim().isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.link),
                                  onPressed: () async {
                                    final raw = profile.website!.trim();
                                    final uri = Uri.tryParse(raw.startsWith('http') ? raw : 'https://$raw');
                                    if (uri == null) return;
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  },
                                ),
                            ],
                          ),
                          if (profile?.bio != null && profile!.bio!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              profile.bio!,
                              style: AppTextStyles.body(context),
                            ),
                          ],
                          const SizedBox(height: 12),
                          userEventsAsync.when(
                            loading: () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                _StatChip(label: 'Active posts', value: '—'),
                                _StatChip(label: 'Archived', value: '0'),
                                _StatChip(label: 'Views', value: '—'),
                              ],
                            ),
                            error: (_, __) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                _StatChip(label: 'Active posts', value: '—'),
                                _StatChip(label: 'Archived', value: '0'),
                                _StatChip(label: 'Views', value: '—'),
                              ],
                            ),
                            data: (events) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatChip(label: 'Active posts', value: events.length.toString()),
                                const _StatChip(label: 'Archived', value: '0'),
                                _StatChip(label: 'Views', value: _totalViews(events).toString()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(text: 'Active'),
                      Tab(text: 'Archived'),
                      Tab(text: 'Bookmarked'),
                    ],
                  ),
                  theme.colorScheme.surface,
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Active
              userEventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(child: Text('No active posts yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) => EventCard(event: events[index]),
                  );
                },
              ),
              // Archived
              const Center(child: Text('No archived posts.')),
              // Bookmarked
              const Center(child: Text('No bookmarked posts yet.')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;

  _SliverAppBarDelegate(this._tabBar, this._backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.titleMedium(context),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.captionMuted(context),
          ),
        ],
      ),
    );
  }
}

int _totalViews(List<EventModel> events) {
  var sum = 0;
  for (final e in events) {
    sum += e.views;
  }
  return sum;
}
