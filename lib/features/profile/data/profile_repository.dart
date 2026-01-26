import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? bio;
  final String? website;
  final String? location;
  final String? businessType;
  final int followersCount;
  final int followingCount;
  final String role;
  final int credits;
  final bool completedWelcome;
  final String? onboardingGoal;
  final DateTime? createdAt;

  String get displayName => fullName ?? username ?? 'User';

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bannerUrl,
    this.bio,
    this.website,
    this.location,
    this.businessType,
    this.followersCount = 0,
    this.followingCount = 0,
    this.role = 'free',
    this.credits = 0,
    this.completedWelcome = false,
    this.onboardingGoal,
    this.createdAt,
  });

  Profile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bannerUrl,
    String? bio,
    String? website,
    String? location,
    String? businessType,
    int? followersCount,
    int? followingCount,
    String? role,
    int? credits,
    bool? completedWelcome,
    String? onboardingGoal,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      businessType: businessType ?? this.businessType,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      role: role ?? this.role,
      credits: credits ?? this.credits,
      completedWelcome: completedWelcome ?? this.completedWelcome,
      onboardingGoal: onboardingGoal ?? this.onboardingGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      businessType: json['business_type'] as String?,
      followersCount: (json['followers_count'] as int?) ?? 0,
      followingCount: (json['following_count'] as int?) ?? 0,
      role: (json['role'] as String?) ?? 'free',
      credits: (json['credits'] as int?) ?? 0,
      completedWelcome: (json['completed_welcome'] as bool?) ?? false,
      onboardingGoal: json['onboarding_goal'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'bio': bio,
      'website': website,
      'location': location,
      'business_type': businessType,
      'followers_count': followersCount,
      'following_count': followingCount,
      'role': role,
      'credits': credits,
      'completed_welcome': completedWelcome,
      'onboarding_goal': onboardingGoal,
      // created_at is usually managed by DB, but including it for local updates if needed.
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<Profile> upsertProfile(Profile profile);
  Future<List<Profile>> searchProfiles(String query);
  Future<void> followUser(String followerId, String followingId);
  Future<void> unfollowUser(String followerId, String followingId);
  Future<bool> isFollowing(String followerId, String followingId);
  Future<List<Profile>> getFollowers(String userId, {int limit = 10});
  Future<List<Profile>> getFollowing(String userId, {int limit = 10});
  Future<List<Profile>> getSocialProof(String currentUserId, String targetUserId, {int limit = 3});
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<Profile?> getProfile(String userId) async {
    final Map<String, dynamic>? response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  @override
  Future<Profile> upsertProfile(Profile profile) async {
    Map<String, dynamic> payload = profile.toJson();

    try {
      final Map<String, dynamic> response = await _supabase
          .from('profiles')
          .upsert(payload)
          .select()
          .single();

      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      // Best-effort compatibility if the remote schema is missing some columns.
      final msg = e.message.toLowerCase();
      final missingColumn = msg.contains('column') && msg.contains('does not exist');
      if (!missingColumn) rethrow;

      payload = Map<String, dynamic>.from(payload)
        ..remove('completed_welcome');

      final Map<String, dynamic> response = await _supabase
          .from('profiles')
          .upsert(payload)
          .select()
          .single();

      return Profile.fromJson(response);
    }
  }

  @override
  Future<List<Profile>> searchProfiles(String query) async {
    final searchBuilder = _supabase.from('profiles').select();
    
    if (query.trim().isNotEmpty) {
      searchBuilder.or('username.ilike.%$query%,full_name.ilike.%$query%');
    }

    final response = await searchBuilder.limit(20);

    return (response as List<dynamic>)
        .map((json) => Profile.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> followUser(String followerId, String followingId) async {
    await _supabase.from('follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });
  }

  @override
  Future<void> unfollowUser(String followerId, String followingId) async {
    await _supabase
        .from('follows')
        .delete()
        .match({'follower_id': followerId, 'following_id': followingId});
  }

  @override
  Future<bool> isFollowing(String followerId, String followingId) async {
    final response = await _supabase
        .from('follows')
        .select('created_at')
        .match({'follower_id': followerId, 'following_id': followingId})
        .maybeSingle();
    return response != null;
  }

  @override
  Future<List<Profile>> getFollowers(String userId, {int limit = 10}) async {
    // In Supabase, you might need to use a join or a specific RPC if the table doesn't have an explicit FK name
    // For this implementation, we assume profiles!follower_id (* ) works if FK is defined.
    try {
      final response = await _supabase
          .from('follows')
          .select('profiles!follower_id (*)')
          .eq('following_id', userId)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Profile.fromJson(json['profiles'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback if the join syntax fails
      return [];
    }
  }

  @override
  Future<List<Profile>> getFollowing(String userId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('profiles!following_id (*)')
          .eq('follower_id', userId)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Profile.fromJson(json['profiles'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Profile>> getSocialProof(String currentUserId, String targetUserId, {int limit = 3}) async {
    // Return recent followers as a simple social proof implementation
    return getFollowers(targetUserId, limit: limit);
  }
}
