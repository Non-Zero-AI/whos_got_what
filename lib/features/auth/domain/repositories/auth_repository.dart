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
  Future<void> signOut();
  Future<void> deleteAccount();
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
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    // In Supabase, users can be deleted via the Admin API or an RPC that calls 
    // delete from auth.users (if permitted). 
    // Since we don't have Admin keys here, we use the 'delete_user_account' RPC 
    // or a direct auth function if available.
    // For now, we'll try calling an RPC 'delete_user' which is a common pattern.
    await _supabase.rpc('delete_user_account');
    await _supabase.auth.signOut();
  }

  @override
  User? get currentUser => _supabase.auth.currentUser;
}
