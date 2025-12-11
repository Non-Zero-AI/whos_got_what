import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/features/auth/data/auth_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(Supabase.instance.client);
});

class ProfileController extends AsyncNotifier<Profile?> {
  @override
  FutureOr<Profile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    final repo = ref.watch(profileRepositoryProvider);
    return await repo.getProfile(user.id);
  }

  Future<void> updateProfile(Profile updated) async {
    final repo = ref.read(profileRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await repo.upsertProfile(updated);
      return saved;
    });
  }

  Future<void> reload() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncData(null);
      return;
    }
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.getProfile(user.id));
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile?>(ProfileController.new);
