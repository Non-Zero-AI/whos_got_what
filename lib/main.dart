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
            // Global Background
            Container(
              decoration: BoxDecoration(
                color: isDark ? null : AppTheme.lightBg,
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.darkGradientStart,
                          AppTheme.darkGradientEnd,
                        ],
                      )
                    : null,
              ),
            ),
            // Noise Overlay
            // Positioned.fill(
            //   child: Image.asset(
            //     'assets/images/noise.png',
            //     repeat: ImageRepeat.repeat,
            //     fit: BoxFit.none,
            //   ),
            // ),
            // App Content
            if (child != null) child,
          ],
        );
      },
    );
  }
}
