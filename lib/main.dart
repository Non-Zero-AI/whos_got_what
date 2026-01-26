import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/core/router/router_provider.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';
import 'package:whos_got_what/features/notifications/data/push_notification_service.dart';
import 'package:whos_got_what/firebase_options.dart';

import 'package:whos_got_what/features/notifications/data/notification_providers.dart';

/// Whether Firebase was successfully initialized
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Push notifications will be disabled.');
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: StreetsideLocalApp()));
}

class StreetsideLocalApp extends ConsumerStatefulWidget {
  const StreetsideLocalApp({super.key});

  @override
  ConsumerState<StreetsideLocalApp> createState() => _StreetsideLocalAppState();
}

class _StreetsideLocalAppState extends ConsumerState<StreetsideLocalApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    // Only initialize if Firebase was set up
    if (!firebaseInitialized) {
      debugPrint('Skipping push notification setup - Firebase not configured');
      return;
    }

    try {
      final pushService = ref.read(pushNotificationServiceProvider);
      await pushService.initialize();
    } catch (e) {
      debugPrint('Failed to initialize push notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // Listen for notification navigation
    ref.listen<String?>(notificationNavigationProvider, (previous, next) {
      if (next != null) {
        router.push('/home/events/$next');
        // Clear the state so we don't navigate again on rebuild
        ref.read(notificationNavigationProvider.notifier).clear();
      }
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.getTheme(mode: themeState.mode),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Stack(
          children: [
            // Layer 1: Diagonal Gradient Background (top-left → bottom-right, 135°)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? AppTheme.darkGradientColors
                          : AppTheme.lightGradientColors,
                ),
              ),
            ),
            // Layer 3: App Content
            if (child != null) child,
          ],
        );
      },
    );
  }
}
