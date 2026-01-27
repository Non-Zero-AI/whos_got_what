import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/auth/presentation/screens/auth_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/home_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/event_calendar_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/create_event_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/event_details_screen.dart';
import 'package:whos_got_what/features/map/presentation/screens/map_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/welcome_onboarding_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/intro_carousel_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/profile_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/follow_list_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/my_events_screen.dart';
import 'package:whos_got_what/features/settings/presentation/screens/settings_screen.dart';
import 'package:whos_got_what/shared/widgets/scaffold_with_navbar.dart';
import 'package:whos_got_what/features/design_system_demo/design_system_demo_screen.dart';
import 'package:whos_got_what/features/payment/presentation/screens/subscription_screen.dart';
import 'package:whos_got_what/features/payment/presentation/screens/payment_screen.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart'; // For Profile type
import 'package:whos_got_what/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:whos_got_what/features/notifications/presentation/notifications_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<AsyncValue<Profile?>>(
      profileControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/home',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      // Wait for auth to initialize
      if (authState.isLoading || !authState.hasValue) return null;

      final currentUser = ref.read(currentUserProvider);
      final isLoggedIn = currentUser != null;
      final path = state.uri.path;
      final isPublicOnboardingRoute =
          path == '/intro' ||
          path == '/onboarding' ||
          path == '/auth' ||
          path == '/welcome';

      final profileAsync = ref.read(profileControllerProvider);
      final profile = profileAsync.value;
      final completedWelcome = profile?.completedWelcome ?? false;

      // Unauthenticated users should only see intro/auth/onboarding/welcome
      if (!isLoggedIn && !isPublicOnboardingRoute) {
        return '/intro';
      }

      if (isLoggedIn) {
        // If welcome already completed, never show intro/welcome again -> Go Home
        if (completedWelcome && isPublicOnboardingRoute) {
          return '/home';
        }

        // If welcome NOT completed, do not redirect if they are on a public route.
        // This prevents bumping them back to /splash if they are navigating to /welcome.
        // And if they specifically navigate to /welcome (via context.go), this redirect returns null (allowed).
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroCarouselScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const AuthScreen(isLoginMode: false),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final isLoginMode = state.extra is bool ? state.extra as bool : false;
          return AuthScreen(isLoginMode: isLoginMode);
        },
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeOnboardingScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/events/create',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder:
            (context, state) =>
                CreateEventScreen(eventId: state.pathParameters['id']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: HomeScreen()),
                routes: [
                  GoRoute(
                    path: 'events/:id',
                    builder:
                        (context, state) => EventDetailsScreen(
                          eventId: state.pathParameters['id']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: EventCalendarScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: MapScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: ProfileScreen()),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'my-events',
                    builder: (context, state) => const MyEventsScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder:
                        (context, state) =>
                            ProfileScreen(userId: state.pathParameters['id']),
                    routes: [
                      GoRoute(
                        path: 'followers',
                        builder:
                            (context, state) => FollowListScreen(
                              userId: state.pathParameters['id']!,
                              showFollowers: true,
                            ),
                      ),
                      GoRoute(
                        path: 'following',
                        builder:
                            (context, state) => FollowListScreen(
                              userId: state.pathParameters['id']!,
                              showFollowers: false,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/design',
        builder: (context, state) => const DesignSystemDemoScreen(),
      ),
    ],
  );
});
