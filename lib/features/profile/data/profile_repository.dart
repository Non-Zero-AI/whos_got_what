import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? bio;
  final String? website;
  final String role;
  final int credits;
  final bool completedWelcome;

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bannerUrl,
    this.bio,
    this.website,
    this.role = 'free',
    this.credits = 0,
    this.completedWelcome = false,
  });

  Profile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bannerUrl,
    String? bio,
    String? website,
    bool? completedWelcome,
  }) {
    return Profile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      role: role,
      credits: credits,
      completedWelcome: completedWelcome ?? this.completedWelcome,
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
      role: (json['role'] as String?) ?? 'free',
      credits: (json['credits'] as int?) ?? 0,
      completedWelcome: (json['completed_welcome'] as bool?) ?? false,
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
      'role': role,
      'credits': credits,
      'completed_welcome': completedWelcome,
    };
  }
}

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<Profile> upsertProfile(Profile profile);
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<Profile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Profile> upsertProfile(Profile profile) async {
    final response = await _supabase
        .from('profiles')
        .upsert(profile.toJson())
        .select()
        .single();

    return Profile.fromJson(response as Map<String, dynamic>);
  }
}
