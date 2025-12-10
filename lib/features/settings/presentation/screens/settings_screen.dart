import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeState.mode == ThemeMode.dark,
            onChanged: (value) => themeNotifier.toggleTheme(value),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ColorOption(color: const Color(0xFF6200EE), selected: themeState.accentColor),
              _ColorOption(color: Colors.blue, selected: themeState.accentColor),
              _ColorOption(color: Colors.red, selected: themeState.accentColor),
              _ColorOption(color: Colors.green, selected: themeState.accentColor),
              _ColorOption(color: Colors.orange, selected: themeState.accentColor),
              _ColorOption(color: Colors.teal, selected: themeState.accentColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends ConsumerWidget {
  final Color color;
  final Color selected;

  const _ColorOption({required this.color, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = color.toARGB32() == selected.toARGB32();
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setAccentColor(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              )
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
