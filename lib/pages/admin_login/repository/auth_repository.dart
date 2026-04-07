import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for handling authentication logic with Supabase.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  /// Signs in the user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Returns the current session, or null if there is no session.
  Session? get currentSession => _client.auth.currentSession;

  /// Returns the current user, or null if there is no user.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
