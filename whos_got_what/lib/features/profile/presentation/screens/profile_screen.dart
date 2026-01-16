import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/shared/widgets/liquid_glass_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: FilledButton(
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
    final displayName = profile?.fullName ?? profile?.username ?? user.email?.split('@').first ?? 'User';
    final handle = profile?.username ?? user.email?.split('@').first;
    
    // Determine Role/Tier
    final role = profile?.role ?? 'regular';
    final isBusiness = role == 'business';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Profile'),
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.1),
                pinned: false,
                floating: true,
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
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.tealAccent.withValues(alpha: 0.2),
                                  AppTheme.amberAccent.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
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
                            top: 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: profile?.avatarUrl != null
                                        ? NetworkImage(profile!.avatarUrl!)
                                        : null,
                                    child: profile?.avatarUrl == null
                                        ? const Icon(Icons.person, size: 50)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(displayName, style: AppTextStyles.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                                        if (handle != null) Text('@$handle', style: AppTextStyles.captionMuted(context)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isBusiness) ...[
                            LiquidGlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              borderRadius: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 16, color: AppTheme.tealAccent),
                                  const SizedBox(width: 8),
                                  Text(
                                    'BUSINESS PRO', // Tier placeholder
                                    style: AppTextStyles.labelSecondary(context).copyWith(
                                      color: AppTheme.tealAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                            Text(profile.bio!, style: AppTextStyles.body(context)),
                            const SizedBox(height: 16),
                          ],
                          
                          userEventsAsync.maybeWhen(
                            data: (events) => Row(
                              children: [
                                Expanded(child: _StatChip(label: 'Posts', value: events.length.toString())),
                                const SizedBox(width: 12),
                                Expanded(child: _StatChip(label: 'Reach', value: _totalViews(events).toString())),
                                const SizedBox(width: 12),
                                Expanded(child: _StatChip(label: 'Bookmarks', value: '12')), // Placeholder
                              ],
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    indicatorColor: AppTheme.tealAccent,
                    labelColor: AppTheme.tealAccent,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'ACTIVE'),
                      Tab(text: 'PAST'),
                      Tab(text: 'SAVED'),
                    ],
                  ),
                  theme.colorScheme.surface.withValues(alpha: 0.05),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              userEventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (events) {
                  if (events.isEmpty) return const Center(child: Text('No active posts yet.'));
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) => EventCard(event: events[index]),
                  );
                },
              ),
              const Center(child: Text('No past posts.')),
              const Center(child: Text('No saved posts.')),
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

  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: _backgroundColor, child: _tabBar);
  }

  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.captionMuted(context)),
        ],
      ),
    );
  }
}

int _totalViews(List<EventModel> events) => events.fold(0, (sum, e) => sum + e.views);
