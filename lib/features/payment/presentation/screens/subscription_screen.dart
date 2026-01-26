import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How will you use Streetside Local?',
              style: AppTextStyles.headlinePrimary(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _RoleCard(
              title: 'Consumer',
              description:
                  'Follow local businesses, discover events, and find the best deals around you.',
              icon: Icons.search,
              isRecommended: false,
              onSelect: () => _updateRole(context, ref, 'free'),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              title: 'Creator',
              description:
                  'Post your own events, promote your business, and connect with local customers.',
              icon: Icons.add_business,
              isRecommended: true,
              onSelect: () => _updateRole(context, ref, 'paid'),
            ),
            const Spacer(),
            Text(
              'You can change this later in settings.',
              style: AppTextStyles.captionMuted(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(
    BuildContext context,
    WidgetRef ref,
    String role,
  ) async {
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;

    final updated = profile.copyWith(role: role);
    await ref.read(profileControllerProvider.notifier).updateProfile(updated);

    if (context.mounted) {
      if (role == 'paid') {
        context.go('/payment');
      } else {
        context.go('/home');
      }
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isRecommended;
  final VoidCallback onSelect;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isRecommended,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelect,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Text(title, style: AppTextStyles.titleLarge(context)),
                if (isRecommended) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: AppTextStyles.labelSecondary(context).copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(description, style: AppTextStyles.body(context)),
          ],
        ),
      ),
    );
  }
}
