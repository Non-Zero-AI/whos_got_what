import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_fab.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.canvasColor;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: NeumorphicFab(
        onPressed: () => context.push('/events/create'),
        backgroundColor: colorScheme.primary,
        child: Icon(
          Icons.add,
          size: 28,
          color: colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            // Top shadow for neumorphic effect
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, -4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
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
                  onTap: () => navigationShell.goBranch(0, initialLocation: false),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.event_available_outlined,
                  activeIcon: Icons.event,
                  label: 'Calendar',
                  onTap: () => navigationShell.goBranch(1, initialLocation: false),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  onTap: () => navigationShell.goBranch(2, initialLocation: false),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.person_outlined,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  onTap: () => navigationShell.goBranch(3, initialLocation: false),
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
    final Color inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final bgColor = theme.canvasColor;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: selected && !_isPressed
              ? [
                  // Neumorphic shadow for selected state
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.2),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ]
              : _isPressed
                  ? [
                      // Inset appearance when pressed
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
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
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? activeColor : inactiveColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
