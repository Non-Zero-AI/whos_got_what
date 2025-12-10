import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get onAuthStateChange;
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthResponse> signInAnonymously();
  Future<void> signOut();
  User? get currentUser;
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signInAnonymously() async {
    return await _supabase.auth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  User? get currentUser => _supabase.auth.currentUser;
}
