import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/theme_provider.dart';
import 'package:whos_got_what/shared/widgets/matte_card.dart';
import 'package:whos_got_what/shared/widgets/raised_button.dart';

class DesignSystemDemoScreen extends ConsumerWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Theme Switcher',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppPalette.values.map((palette) {
              return ChoiceChip(
                label: Text(palette.name),
                selected: themeState.palette == palette,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(themeProvider.notifier).setPalette(palette);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          const Text(
            'Raised Buttons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Center(
            child: RaisedButton(
              onPressed: () {},
              child: const Text('Primary ACTION'),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: RaisedButton(
              onPressed: () {},
              width: 200,
              height: 60,
              child: const Text('Wide Button'),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Matte Cards',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          MatteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Title',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is a matte card component. It uses diffuse shadows to appear like a floating plate.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: MatteCard(
                  height: 100,
                  child: Center(child: Text('Small Card')),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: MatteCard(
                  height: 100,
                  child: Center(child: Text('Small Card')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
