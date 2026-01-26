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
import 'package:whos_got_what/shared/widgets/optimized_image.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';
import 'package:whos_got_what/core/providers/scroll_provider.dart';
import 'package:whos_got_what/features/notifications/data/notification_repository.dart';
import 'package:whos_got_what/features/notifications/data/notification_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthUser = ref.watch(currentUserProvider);
    final targetUserId = widget.userId ?? currentAuthUser?.id;

    if (targetUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/auth'),
            child: const Text('Sign In'),
          ),
        ),
      );
    }

    final isOwnProfile =
        widget.userId == null || widget.userId == currentAuthUser?.id;
    final theme = Theme.of(context);
    final userEventsAsync = ref.watch(userEventsByIdProvider(targetUserId));

    final profileAsync =
        isOwnProfile
            ? ref.watch(profileControllerProvider)
            : ref.watch(profileProvider(targetUserId));

    final profile = profileAsync.value;
    final handle = profile?.username;

    final initialTabIndex = 0; // Always start with Active posts (tab 0)
    final tabCount = isOwnProfile ? 3 : 1;

    // Listen for scroll-to-top requests
    ref.listen<int>(profileScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return DefaultTabController(
      length: tabCount,
      initialIndex: initialTabIndex,
      child: AppTheme.buildBackground(
        context: context,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              if (isOwnProfile) {
                await ref.read(profileControllerProvider.notifier).reload();
              } else {
                ref.invalidate(profileProvider(targetUserId));
              }
              ref.invalidate(userEventsByIdProvider(targetUserId));
              await ref.read(userEventsByIdProvider(targetUserId).future);
            },
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 0,
                    floating: true,
                    snap: true,
                    pinned: true,
                    backgroundColor:
                        theme.colorScheme.surface, // Use surface color
                    surfaceTintColor: theme.colorScheme.surface,
                    elevation: 0,
                    automaticallyImplyLeading: !isOwnProfile,
                    title: GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        isOwnProfile
                            ? 'Profile'
                            : profile?.displayName ?? 'Profile',
                        style: AppTextStyles.titleLarge(context),
                      ),
                    ),
                    centerTitle: false,
                    actions: [
                      if (isOwnProfile) ...[
                        if (profile != null && profile.credits > 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _CreditsBadge(credits: profile.credits),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => context.go('/profile/settings'),
                        ),
                      ],
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner + avatar
                        SizedBox(
                          height: 200,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: OptimizedImage(
                                  imageUrl: profile?.bannerUrl ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: _FallbackBanner(theme: theme),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 0,
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: theme.canvasColor,
                                  child: CircleAvatar(
                                    radius: 41,
                                    backgroundColor: theme.colorScheme.surface,
                                    child: OptimizedImage(
                                      imageUrl: profile?.avatarUrl ?? '',
                                      width: 82,
                                      height: 82,
                                      borderRadius: BorderRadius.circular(41),
                                      placeholder: const Icon(
                                        Icons.person,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (!isOwnProfile)
                                Positioned(
                                  right: 16,
                                  bottom: -10,
                                  child: _FollowButton(targetId: targetUserId),
                                ),
                            ],
                          ),
                        ),
                        // User Info section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              // Name & Grade/Upgrade Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile?.displayName ?? 'User',
                                            style: AppTextStyles.titleLarge(
                                              context,
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (profile?.role != null &&
                                            profile!.role != 'free') ...[
                                          const SizedBox(width: 8),
                                          _ProBadge(role: profile.role),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isOwnProfile && profile?.role == 'free')
                                    NeumorphicContainer(
                                      padding: EdgeInsets.zero,
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => context.push('/payment'),
                                        icon: const Icon(
                                          Icons.star_outline,
                                          size: 16,
                                        ),
                                        label: const Text('Go Pro'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.primary,
                                          foregroundColor:
                                              theme.colorScheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (handle != null && handle.trim().isNotEmpty)
                                Text(
                                  '@${handle.trim()}',
                                  style: AppTextStyles.captionMuted(
                                    context,
                                  ).copyWith(fontSize: 15),
                                ),

                              // Bio
                              if (profile?.bio != null &&
                                  profile!.bio!.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  profile.bio!,
                                  style: AppTextStyles.body(context),
                                ),
                              ],

                              // Metadata
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  if (profile?.businessType != null &&
                                      profile!.businessType!.isNotEmpty)
                                    _MetadataItem(
                                      icon: Icons.business_center_outlined,
                                      label: profile.businessType!,
                                    ),
                                  if (profile?.location != null &&
                                      profile!.location!.isNotEmpty)
                                    InkWell(
                                      onTap: () async {
                                        final query = Uri.encodeComponent(
                                          profile.location!,
                                        );
                                        final url = Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=$query',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        }
                                      },
                                      child: _MetadataItem(
                                        icon: Icons.location_on_outlined,
                                        label: profile.location!,
                                        isLink: true,
                                      ),
                                    ),
                                  if (profile?.createdAt != null)
                                    _MetadataItem(
                                      icon: Icons.calendar_today_outlined,
                                      label:
                                          'Joined ${_formatJoinedDate(profile!.createdAt!)}',
                                    ),
                                ],
                              ),

                              // Following/Followers
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _CountItem(
                                    count: profile?.followingCount ?? 0,
                                    label: 'Following',
                                    onTap:
                                        () => context.push(
                                          '/profile/$targetUserId/following',
                                        ),
                                  ),
                                  const SizedBox(width: 20),
                                  _CountItem(
                                    count: profile?.followersCount ?? 0,
                                    label: 'Followers',
                                    onTap:
                                        () => context.push(
                                          '/profile/$targetUserId/followers',
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              _FollowedByRow(targetId: targetUserId),

                              // Stats section
                              const SizedBox(height: 8),
                              userEventsAsync.when(
                                loading:
                                    () => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _SimpleStat(
                                          label: 'Active posts',
                                          value: '—',
                                        ),
                                        _SimpleStat(label: 'Views', value: '—'),
                                      ],
                                    ),
                                error: (_, __) => const SizedBox.shrink(),
                                data:
                                    (events) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _SimpleStat(
                                          label: 'Active posts',
                                          value: events.length.toString(),
                                        ),
                                        _SimpleStat(
                                          label: 'Views',
                                          value: _totalViews(events).toString(),
                                        ),
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
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    snap: true,
                    backgroundColor:
                        theme.colorScheme.surface, // Solid background
                    surfaceTintColor: theme.colorScheme.surface,
                    elevation: 1,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Container(
                        color: theme.colorScheme.surface, // Solid background
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          dividerHeight: 0,
                          indicatorColor: theme.colorScheme.primary,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: theme.colorScheme.onSurface,
                          unselectedLabelColor: theme.colorScheme.onSurface
                              .withOpacity(0.6),
                          tabs:
                              isOwnProfile
                                  ? const [
                                    Tab(text: 'Active'),
                                    Tab(text: 'Archived'),
                                    Tab(text: 'Bookmarked'),
                                  ]
                                  : const [Tab(text: 'Posts')],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children:
                    isOwnProfile
                        ? [
                          _buildEventsList(
                            ref,
                            userEventsAsync.whenData(
                              (events) =>
                                  events
                                      .where(
                                        (e) =>
                                            !(e.endDate ?? e.startDate)
                                                .isBefore(DateTime.now()),
                                      )
                                      .toList(),
                            ),
                            'No active posts yet.',
                          ),
                          _buildEventsList(
                            ref,
                            userEventsAsync.whenData(
                              (events) =>
                                  events
                                      .where(
                                        (e) => (e.endDate ?? e.startDate)
                                            .isBefore(DateTime.now()),
                                      )
                                      .toList(),
                            ),
                            'No archived posts.',
                          ),
                          _buildEventsList(
                            ref,
                            ref.watch(bookmarkedEventsProvider),
                            'No bookmarked posts yet.',
                          ),
                        ]
                        : [
                          _buildEventsList(
                            ref,
                            userEventsAsync,
                            'No posts yet.',
                          ),
                        ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(
    WidgetRef ref,
    AsyncValue<List<EventModel>> asyncEvents,
    String emptyMessage,
  ) {
    return asyncEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (events) {
        if (events.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder:
              (context, index) =>
                  EventCard(event: events[index], heroTagPrefix: 'profile'),
        );
      },
    );
  }
}

class _ProBadge extends StatelessWidget {
  final String role;
  const _ProBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlimited = role == 'unlimited';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isUnlimited
                ? Colors.amber.withValues(alpha: 0.2)
                : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              isUnlimited
                  ? Colors.amber
                  : theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color:
              isUnlimited
                  ? Colors.amber[900]
                  : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _CreditsBadge extends StatelessWidget {
  final int credits;
  const _CreditsBadge({required this.credits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$credits Credits',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final String targetId;
  const _FollowButton({required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(isFollowingProvider(targetId));
    final theme = Theme.of(context);

    return followingAsync.when(
      data:
          (isFollowing) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification bell button (only show when following)
              if (isFollowing) _NotificationBellButton(targetId: targetId),
              if (isFollowing) const SizedBox(width: 8),
              // Follow button
              NeumorphicContainer(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(20),
                child: ElevatedButton(
                  onPressed:
                      () => ref
                          .read(socialControllerProvider.notifier)
                          .toggleFollow(targetId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowing
                            ? theme.colorScheme.surface
                            : theme.colorScheme.onSurface,
                    foregroundColor:
                        isFollowing
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.surface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Bell button to subscribe/unsubscribe to notifications from a profile
class _NotificationBellButton extends ConsumerWidget {
  final String targetId;
  const _NotificationBellButton({required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribedAsync = ref.watch(
      isSubscribedToNotificationsProvider(targetId),
    );
    final theme = Theme.of(context);

    return isSubscribedAsync.when(
      data: (isSubscribed) {
        return NeumorphicContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(20),
          child: IconButton(
            onPressed: () {
              ref
                  .read(notificationControllerProvider.notifier)
                  .toggleSubscription(targetId);

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSubscribed
                        ? 'Notifications turned off for this profile'
                        : 'You\'ll be notified when they post new events',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none_outlined,
              color:
                  isSubscribed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            tooltip:
                isSubscribed
                    ? 'Turn off notifications'
                    : 'Get notified when they post',
            style: IconButton.styleFrom(
              backgroundColor:
                  isSubscribed
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : theme.colorScheme.surface,
              padding: const EdgeInsets.all(10),
            ),
          ),
        );
      },
      loading:
          () => const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FollowedByRow extends ConsumerWidget {
  final String targetId;
  const _FollowedByRow({required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proofAsync = ref.watch(socialProofProvider(targetId));

    return proofAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20.0 + (profiles.length - 1) * 15.0,
                height: 24,
                child: Stack(
                  children: List.generate(profiles.length, (index) {
                    return Positioned(
                      left: index * 15.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundImage:
                              profiles[index].avatarUrl != null
                                  ? NetworkImage(profiles[index].avatarUrl!)
                                  : null,
                          child:
                              profiles[index].avatarUrl == null
                                  ? const Icon(Icons.person, size: 10)
                                  : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildSocialProofText(profiles),
                  style: AppTextStyles.captionMuted(
                    context,
                  ).copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _buildSocialProofText(List<Profile> profiles) {
    if (profiles.isEmpty) return "";
    final names = profiles.take(2).map((p) => p.displayName).toList();
    if (profiles.length == 1) return "Followed by ${names[0]}";
    if (profiles.length == 2) return "Followed by ${names[0]} and ${names[1]}";
    return "Followed by ${names[0]}, ${names[1]} and ${profiles.length - 2} others";
  }
}

class _SimpleStat extends StatelessWidget {
  const _SimpleStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: AppTextStyles.titleMedium(context)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.captionMuted(context)),
      ],
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

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLink;

  const _MetadataItem({
    required this.icon,
    required this.label,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style:
              isLink
                  ? AppTextStyles.labelPrimary(context).copyWith(fontSize: 14)
                  : AppTextStyles.captionMuted(context).copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _CountItem extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onTap;

  const _CountItem({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: AppTextStyles.body(context).copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.captionMuted(context)),
          ],
        ),
      ),
    );
  }
}

String _formatJoinedDate(DateTime date) {
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

class _FallbackBanner extends StatelessWidget {
  final ThemeData theme;
  const _FallbackBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
