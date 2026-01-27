import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_fab.dart';
import 'package:whos_got_what/features/events/presentation/screens/home_screen.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';

import 'package:whos_got_what/core/providers/dev_mode_provider.dart';
import 'package:whos_got_what/core/providers/scroll_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.canvasColor;

    final profileAsync = ref.watch(profileControllerProvider);
    final profile = profileAsync.value;
    final isPaid = profile?.role == 'paid' || profile?.role == 'unlimited';
    final isDevMode = ref.watch(devModeProvider);

    // Simplified FAB visibility: Show on all main branch roots
    final bool shouldShowFab = true;

    return Scaffold(
      body: navigationShell,
      floatingActionButton:
          shouldShowFab
              ? NeumorphicFab(
                onPressed: () {
                  if (isPaid || isDevMode) {
                    context.push('/events/create');
                  } else {
                    context.push('/payment');
                  }
                },
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.add, size: 28, color: colorScheme.onPrimary),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            // Top shadow for neumorphic effect
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
            BoxShadow(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.4),
              offset: const Offset(0, -0.3),
              blurRadius: 1,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  onTap: () {
                    final isHome = navigationShell.currentIndex == 0;
                    if (isHome) {
                      final currentType = ref.read(searchTypeProvider);
                      if (currentType == SearchType.people) {
                        ref.read(searchTypeProvider.notifier).set(SearchType.events);
                      } else {
                        navigationShell.goBranch(0, initialLocation: true);
                      }
                    } else {
                      navigationShell.goBranch(0, initialLocation: false);
                    }
                  },
                ),
                _NavItem(
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.event_available_outlined,
                  activeIcon: Icons.event,
                  label: 'Calendar',
                  onTap:
                      () => navigationShell.goBranch(1, initialLocation: false),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  onTap:
                      () => navigationShell.goBranch(2, initialLocation: false),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.person_outlined,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    final isProfile = navigationShell.currentIndex == 3;
                    if (isProfile) {
                      // Go to root of branch (pops settings)
                      navigationShell.goBranch(3, initialLocation: true);
                      // Trigger scroll to top via provider
                      ref.read(profileScrollToTopProvider.notifier).scrollToTop();
                    } else {
                      navigationShell.goBranch(3, initialLocation: false);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool selected = widget.index == widget.currentIndex;
    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.7,
    );
    final bgColor = theme.canvasColor;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow:
              selected && !_isPressed
                  ? [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                  : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient:
                selected && !_isPressed
                    ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
                        Colors.transparent,
                      ],
                    )
                    : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? widget.activeIcon : widget.icon,
                  color: selected ? activeColor : inactiveColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
