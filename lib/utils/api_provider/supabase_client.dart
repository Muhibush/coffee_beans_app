import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized accessor for the Supabase client instance.
/// Used by all repositories for database operations.
class SupabaseClientProvider {
  SupabaseClientProvider._();

  /// Returns the singleton Supabase client.
  static SupabaseClient get client => Supabase.instance.client;
}
