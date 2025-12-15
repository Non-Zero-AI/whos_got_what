import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/core/router/router_provider.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: WhosGotWhatApp()));
}

class WhosGotWhatApp extends ConsumerWidget {
  const WhosGotWhatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.getTheme(
        palette: themeState.palette,
        mode: themeState.mode,
        accentColor: themeState.accentColor,
      ),
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
            // Layer 2: Noise Texture Overlay
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.04 : 0.03, // Dark: 0.03-0.05, Light: 0.02-0.04
                child: Image.asset(
                  'assets/images/noise.png',
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.cover,
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
