import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/shared/widgets/post_type_badge.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:whos_got_what/shared/widgets/optimized_image.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/data/user_events_provider.dart';

class EventCard extends ConsumerStatefulWidget {
  final EventModel event;
  final String heroTagPrefix;

  const EventCard({
    super.key,
    required this.event,
    this.heroTagPrefix = 'event',
  });

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  bool? _isLikedOverride;
  bool? _isBookmarkedOverride;

  bool get _isBookmarked => _isBookmarkedOverride ?? widget.event.isBookmarked;

  @override
  void didUpdateWidget(EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.isBookmarked != widget.event.isBookmarked) {
      _isBookmarkedOverride = null;
    }
  }

  Future<void> _handleToggleLike() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final newVal = !(_isLikedOverride ?? false);
    setState(() => _isLikedOverride = newVal);

    try {
      await ref
          .read(eventRepositoryProvider)
          .toggleLike(user.id, widget.event.id);
      // We don't invalidate global events here to avoid jumpy UI,
      // but we could if we wanted total sync.
    } catch (e) {
      if (mounted) setState(() => _isLikedOverride = !newVal);
    }
  }

  Future<void> _handleToggleBookmark() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final currentVal = _isBookmarked;
    final newVal = !currentVal;
    setState(() => _isBookmarkedOverride = newVal);

    try {
      final repo = ref.read(eventRepositoryProvider);
      await repo.toggleBookmark(user.id, widget.event.id);

      // Only invalidate the bookmark provider so the Profile updates!
      ref.invalidate(bookmarkedEventsProvider);
      // Don't invalidate eventsProvider as it causes app reload
    } catch (e) {
      if (mounted) setState(() => _isBookmarkedOverride = currentVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void openDetails() => context.go('/home/events/${widget.event.id}');

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: 24),
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      onTap: openDetails,
      surfaceColor: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header with post type badge
          Stack(
            children: [
              Hero(
                tag: '${widget.heroTagPrefix}-img-${widget.event.id}',
                child: OptimizedImage(
                  imageUrl: widget.event.imageUrl,
                  height: 220,
                  width: double.infinity,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
              // Post Type Badge
              Positioned(
                top: 12,
                left: 12,
                child: PostTypeBadge(postType: widget.event.postType),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Creator Info ---
                Consumer(
                  builder: (context, ref, _) {
                    final profileAsync = ref.watch(
                      profileProvider(widget.event.organizerId),
                    );
                    return profileAsync.when(
                      data:
                          (profile) => GestureDetector(
                            onTap:
                                () => context.push(
                                  '/profile/${widget.event.organizerId}',
                                ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage:
                                        profile?.avatarUrl != null
                                            ? NetworkImage(profile!.avatarUrl!)
                                            : null,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child:
                                        profile?.avatarUrl == null
                                            ? Icon(
                                              Icons.person,
                                              size: 12,
                                              color: theme.colorScheme.primary,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      profile?.username ??
                                          profile?.fullName ??
                                          'Organizer',
                                      style: AppTextStyles.labelSecondary(
                                        context,
                                      ).copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 14,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      loading: () => const SizedBox(height: 32),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                // Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatEventTimeRange(widget.event),
                          style: AppTextStyles.eventDateTime(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  widget.event.title,
                  style: AppTextStyles.eventTitle(context),
                ),
                const SizedBox(height: 6),
                // Location
                GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri(
                      scheme: 'https',
                      host: 'maps.google.com',
                      queryParameters: {'q': widget.event.location},
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: AppTextStyles.eventLocation(context).copyWith(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Description snippet
                Text(
                  widget.event.description,
                  style: AppTextStyles.eventDescription(context),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Views + check-in info
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.event.views} views',
                      style: AppTextStyles.eventMetadata(context),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.push_pin_outlined,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Check-in',
                      style: AppTextStyles.eventMetadata(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Social row + Details button
                Row(
                  children: [
                    NeumorphicContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(24),
                      width: 54, // Widened for count
                      height: 40,
                      onTap: _handleToggleLike,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                                (_isLikedOverride ?? false)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    (_isLikedOverride ?? false)
                                        ? Colors.red
                                        : colorScheme.onSurface,
                                size: 18,
                              )
                              .animate(
                                target: (_isLikedOverride ?? false) ? 1 : 0,
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                                duration: 200.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.event.likes + ((_isLikedOverride ?? false) ? 1 : 0)}',
                            style: AppTextStyles.labelSecondary(
                              context,
                            ).copyWith(
                              color:
                                  (_isLikedOverride ?? false)
                                      ? Colors.red
                                      : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeumorphicContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(24),
                      width: 40,
                      height: 40,
                      onTap: () {},
                      child: Icon(
                        Icons.share_outlined,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeumorphicContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(24),
                      width: 54, // Widened for count
                      height: 40,
                      onTap: _handleToggleBookmark,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                                _isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    _isBookmarked
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                size: 18,
                              )
                              .animate(target: _isBookmarked ? 1 : 0)
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                                duration: 200.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.event.bookmarksCount + (_isBookmarked && !widget.event.isBookmarked ? 1 : (!_isBookmarked && widget.event.isBookmarked ? -1 : 0))}',
                            style: AppTextStyles.labelSecondary(
                              context,
                            ).copyWith(
                              color:
                                  _isBookmarked
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: openDetails,
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

String _formatEventTimeRange(EventModel event) {
  final start = event.startDate;
  final end = event.endDate;

  final dateFormatter = DateFormat('MMM d, y');
  final timeFormatter = DateFormat('h:mm a');

  // All-day event: show just date + "All Day"
  if (event.isAllDay) {
    return '${dateFormatter.format(start)} • All Day';
  }

  // No end time: show single timestamp
  if (end == null) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}';
  }

  // Same-day range: "Nov 11, 2025 • 6:00–8:00 PM"
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) {
    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}–${timeFormatter.format(end)}';
  }

  // Multi-day range: "Nov 11, 6:00 PM – Nov 12, 9:00 AM"
  final shortDateFormatter = DateFormat('MMM d');
  return '${shortDateFormatter.format(start)}, ${timeFormatter.format(start)} – '
      '${shortDateFormatter.format(end)}, ${timeFormatter.format(end)}';
}
