import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/presentation/widgets/event_card.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/shared/widgets/optimized_image.dart';
import 'package:whos_got_what/features/notifications/data/notification_providers.dart';

import 'package:whos_got_what/features/profile/presentation/widgets/profile_qr_dialog.dart';

enum SearchType { events, people }

class SearchTypeNotifier extends Notifier<SearchType> {
  @override
  SearchType build() => SearchType.events;
  void set(SearchType type) => state = type;
}

final searchTypeProvider = NotifierProvider<SearchTypeNotifier, SearchType>(
  SearchTypeNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(eventRepositoryProvider);
  if (query.isEmpty) {
    // Return only active (non-archived) events for home feed
    final allEvents = await ref.watch(eventsProvider.future);
    final activeEvents =
        allEvents.where((event) {
          final now = DateTime.now();
          // Event is considered archived if its end time has passed
          final eventEnd = event.endDate ?? event.startDate;
          return eventEnd.isAfter(now);
        }).toList();
    return activeEvents;
  }
  return repo.searchEvents(query);
});

final filteredPeopleProvider = FutureProvider<List<Profile>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(profileRepositoryProvider);
  if (query.isEmpty) {
    // Show some default users if query is empty
    return repo.searchProfiles(
      '',
    ); // Assuming empty query returns all or a subset
  }
  return repo.searchProfiles(query);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchType = ref.watch(searchTypeProvider);
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ProfileQRCodeDialog(),
              );
            },
          ),
          title: Text(
            AppConstants.appName,
            style: AppTextStyles.titleLarge(context),
          ),
          centerTitle: true,
          actions: [_NotificationBadgeIcon()],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: _searchController,
                      onChanged:
                          (val) => ref
                              .read(searchQueryProvider.notifier)
                              .setQuery(val),
                      decoration: InputDecoration(
                        hintText:
                            searchType == SearchType.events
                                ? 'Search events...'
                                : 'Search people...',
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        suffixIcon:
                            query.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .clear();
                                  },
                                )
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _SearchChip(
                        label: 'Events',
                        isActive: searchType == SearchType.events,
                        onTap:
                            () => ref
                                .read(searchTypeProvider.notifier)
                                .set(SearchType.events),
                      ),
                      const SizedBox(width: 8),
                      _SearchChip(
                        label: 'People',
                        isActive: searchType == SearchType.people,
                        onTap:
                            () => ref
                                .read(searchTypeProvider.notifier)
                                .set(SearchType.people),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body:
            searchType == SearchType.events
                ? _buildEventsList()
                : _buildPeopleList(),
      ),
    );
  }

  Widget _buildEventsList() {
    final eventsAsync = ref.watch(filteredEventsProvider);
    return eventsAsync.when(
      data:
          (events) => RefreshIndicator(
            onRefresh: () {
              ref.read(searchQueryProvider.notifier).clear();
              _searchController.clear();
              return ref.refresh(eventsProvider.future);
            },
            child:
                events.isEmpty
                    ? _buildEmptyState("No events found.")
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder:
                          (context, index) => EventCard(event: events[index]),
                    ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildPeopleList() {
    final peopleAsync = ref.watch(filteredPeopleProvider);
    return peopleAsync.when(
      data:
          (people) =>
              people.isEmpty
                  ? _buildEmptyState(
                    ref.watch(searchQueryProvider).isEmpty
                        ? "Search for users, vendors, or businesses."
                        : "No users found.",
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: people.length,
                    itemBuilder:
                        (context, index) =>
                            UserMiniCard(profile: people[index]),
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Opacity(
            opacity: 0.6,
            child: Column(
              children: [
                const Icon(Icons.search_off_outlined, size: 64),
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.body(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class UserMiniCard extends StatelessWidget {
  final Profile profile;
  const UserMiniCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/profile/${profile.id}'),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: ClipOval(
                  child: OptimizedImage(
                    imageUrl: profile.avatarUrl ?? '',
                    width: 52,
                    height: 52,
                    placeholder: const Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (profile.username != null)
                      Text(
                        '@${profile.username}',
                        style: AppTextStyles.captionMuted(context),
                      ),
                  ],
                ),
              ),
              if (profile.businessType != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profile.businessType!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBadgeIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () => context.push('/notifications'),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
