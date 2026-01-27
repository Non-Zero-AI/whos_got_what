import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/core/constants/app_runtime_config.dart';
import 'package:whos_got_what/core/router/router_provider.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';
import 'package:whos_got_what/features/notifications/data/push_notification_service.dart';
import 'package:whos_got_what/firebase_options.dart';

import 'package:whos_got_what/features/notifications/data/notification_providers.dart';

/// Whether Firebase was successfully initialized
bool firebaseInitialized = false;

void _validateRequiredConfig() {
  final missing = <String>[];

  if (AppConstants.supabaseUrl.isEmpty) {
    missing.add('SUPABASE_URL');
  }

  if (AppConstants.supabaseAnonKey.isEmpty) {
    missing.add('SUPABASE_ANON_KEY');
  }

  if (missing.isNotEmpty) {
    throw StateError(
      'Missing required configuration: ${missing.join(', ')}. '
      'Provide values via --dart-define or DART_DEFINES in build settings.',
    );
  }
}

String _readConfigValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

Future<void> _loadRemoteConfig(SupabaseClient client) async {
  const functionName = String.fromEnvironment(
    'PUBLIC_CONFIG_FUNCTION',
    defaultValue: 'public-config',
  );

  if (functionName.isEmpty) {
    return;
  }

  try {
    final response = await client.functions.invoke(functionName);
    final payload = response.data;
    Map<String, dynamic>? data;

    if (payload is Map) {
      data = payload.cast<String, dynamic>();
    } else if (payload is String) {
      final decoded = json.decode(payload);
      if (decoded is Map) {
        data = decoded.cast<String, dynamic>();
      }
    }

    if (data == null) {
      debugPrint('Remote config response is not a map.');
      return;
    }

    final stripeKey = _readConfigValue(data, [
      'stripe_publishable_key',
      'stripePublishableKey',
      'stripeKey',
      'STRIPE_PUB_KEY',
    ]);

    final mapsKey = _readConfigValue(data, [
      'google_maps_api_key',
      'googleMapsApiKey',
      'googleMapsKey',
      'GOOGLE_MAPS_API',
    ]);

    if (stripeKey.isNotEmpty) {
      AppRuntimeConfig.stripePublishableKey = stripeKey;
    }

    if (mapsKey.isNotEmpty) {
      AppRuntimeConfig.googleMapsApiKey = mapsKey;
    }
  } catch (e) {
    debugPrint('Failed to load remote config: $e');
  }
}

Future<void> _configureStripe() async {
  final publishableKey = AppRuntimeConfig.stripePublishableKey;
  if (publishableKey.isEmpty) {
    debugPrint('Stripe publishable key is missing.');
    return;
  }

  Stripe.publishableKey = publishableKey;
  await Stripe.instance.applySettings();
}

void _warnIfOptionalConfigMissing() {
  if (AppRuntimeConfig.googleMapsApiKey.isEmpty) {
    debugPrint(
      'Google Maps API key is missing. Maps/Places features may not work.',
    );
  }

  if (AppRuntimeConfig.stripePublishableKey.isEmpty) {
    debugPrint('Stripe publishable key is missing. Payments disabled.');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _validateRequiredConfig();

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

  await _loadRemoteConfig(Supabase.instance.client);
  await _configureStripe();
  _warnIfOptionalConfigMissing();

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
                  colors: isDark
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
