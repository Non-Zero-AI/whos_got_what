import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/auth/presentation/screens/auth_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/home_screen.dart';
import 'package:whos_got_what/features/events/presentation/screens/event_details_screen.dart';
import 'package:whos_got_what/features/map/presentation/screens/map_screen.dart';
import 'package:whos_got_what/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:whos_got_what/features/profile/presentation/screens/profile_screen.dart';
import 'package:whos_got_what/features/settings/presentation/screens/settings_screen.dart';
import 'package:whos_got_what/shared/widgets/scaffold_with_navbar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session?.user != null;
      final isAuthRoute = state.uri.path == '/auth' || state.uri.path == '/onboarding';

      if (authState.isLoading) return null; // Wait for loading

      if (!isLoggedIn && !isAuthRoute) {
        return '/onboarding'; 
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home'; 
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
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
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
