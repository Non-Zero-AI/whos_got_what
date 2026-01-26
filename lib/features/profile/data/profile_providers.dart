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

  /// Manually update the state (used for optimistic updates)
  void setProfile(Profile? profile) {
    state = AsyncData(profile);
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

final profileProvider = FutureProvider.family<Profile?, String>((ref, id) {
  return ref.watch(profileRepositoryProvider).getProfile(id);
});

final isFollowingProvider = FutureProvider.family<bool, String>((ref, targetId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref.watch(profileRepositoryProvider).isFollowing(user.id, targetId);
});

final followersProvider = FutureProvider.family<List<Profile>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getFollowers(userId);
});

final followingProvider = FutureProvider.family<List<Profile>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getFollowing(userId);
});

final socialProofProvider = FutureProvider.family<List<Profile>, String>((ref, targetId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(profileRepositoryProvider).getSocialProof(user.id, targetId);
});

class SocialController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleFollow(String targetId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repo = ref.read(profileRepositoryProvider);
    final isFollowing = await repo.isFollowing(user.id, targetId);

    // 1. Optimistically update my profile (followingCount)
    final myProfile = ref.read(profileControllerProvider).value;
    if (myProfile != null) {
      final newMe = myProfile.copyWith(
        followingCount: isFollowing 
            ? myProfile.followingCount - 1 
            : myProfile.followingCount + 1,
      );
      ref.read(profileControllerProvider.notifier).setProfile(newMe);
    }

    // 3. Perform the actual action
    if (isFollowing) {
      await repo.unfollowUser(user.id, targetId);
    } else {
      await repo.followUser(user.id, targetId);
    }

    // 4. BRIEF DELAY to allow Supabase DB Triggers to process counts
    // Without this, invalidating instantly often fetches the PRE-TRIGGER values.
    await Future.delayed(const Duration(milliseconds: 1200));

    // 5. Aggressively invalidate to ensure consistency
    ref.invalidate(isFollowingProvider(targetId));
    ref.invalidate(profileProvider(targetId));
    ref.invalidate(profileControllerProvider);
    ref.invalidate(followersProvider(targetId));
    ref.invalidate(followingProvider(user.id));
    ref.invalidate(followersProvider(user.id)); // Just in case
    ref.invalidate(followingProvider(targetId)); // Just in case
  }
}

final socialControllerProvider = NotifierProvider<SocialController, void>(SocialController.new);
