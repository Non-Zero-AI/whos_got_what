import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/auth/presentation/screens/auth_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/home_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/event_calendar_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/create_event_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/event_details_screen.dart';
import 'package:whos_got_what/features/map/presentation/screens/map_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/welcome_onboarding_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/intro_carousel_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/profile_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/my_events_screen.dart';
import 'package:whos_got_what/features/settings/presentation/screens/settings_screen.dart';
import 'package:whos_got_what/shared/widgets/scaffold_with_navbar.dart';
import 'package:whos_got_what/features/design_system_demo/design_system_demo_screen.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/intro',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session?.user != null;
      final isAuthRoute =
          state.uri.path == '/auth' || state.uri.path == '/onboarding' || state.uri.path == '/welcome';

      final profileAsync = ref.read(profileControllerProvider);
      final profile = profileAsync.value;
      final completedWelcome = profile?.completedWelcome ?? false;

      if (authState.isLoading) return null; // Wait for loading

      // Unauthenticated users should only see intro/auth/onboarding/welcome
      if (!isLoggedIn && !isAuthRoute) {
        return '/intro';
      }

      if (isLoggedIn) {
        // While profile/completedWelcome is still loading, don't force redirects yet
        if (profileAsync.isLoading) {
          return null;
        }

        // After successful auth, if welcome not completed, send to welcome
        if (!completedWelcome && state.uri.path != '/welcome') {
          return '/welcome';
        }

        // If welcome already completed, never show /welcome again
        if (completedWelcome && state.uri.path == '/welcome') {
          return '/home';
        }

        // If already logged in and you somehow navigate to /onboarding
        // (e.g. from the intro CTA with an existing session), send to home
        if (state.uri.path == '/onboarding') {
          return '/home';
        }
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
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeOnboardingScreen(),
      ),
      GoRoute(
        path: '/events/create',
        builder: (context, state) => const CreateEventScreen(),
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
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'events/:id',
                    builder: (context, state) => EventDetailsScreen(eventId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const EventCalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'my-events',
                    builder: (context, state) => const MyEventsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/design',
        builder: (context, state) => const DesignSystemDemoScreen(),
      ),
    ],
  );
});
