import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/profile/settings'),
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Sign In'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user.email ?? 'No Email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('My Events'),
                  onTap: () {}, // TODO
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Bookmarked Events'),
                  onTap: () {}, // TODO
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) context.go('/auth');
                  },
                ),
              ],
            ),
    );
  }
}
