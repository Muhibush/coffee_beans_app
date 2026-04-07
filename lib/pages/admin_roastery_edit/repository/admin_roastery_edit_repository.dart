import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/roastery.dart';
import '../../../utils/api_provider/supabase_client.dart';

class AdminRoasteryEditRepository {
  final SupabaseClient _client;

  AdminRoasteryEditRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  /// Fetches a Roastery from Supabase.
  /// If [id] is null, returns an empty template for creation.
  Future<Roastery> getRoastery(String? id) async {
    if (id == null) {
      return const Roastery(
        id: 'new',
        name: '',
        city: '',
        beanCount: 0,
        isActive: true,
        bio: '',
        socialLinks: {},
      );
    }

    final response = await _client
        .from('roasteries')
        .select()
        .eq('id', id)
        .single();

    return Roastery.fromJson(response);
  }

  /// Saves a Roastery to Supabase (insert or update via upsert).
  Future<void> saveRoastery(Roastery roastery) async {
    await _client.from('roasteries').upsert(roastery.toJson());
  }

  /// Deletes a Roastery by id.
  Future<void> deleteRoastery(String id) async {
    await _client.from('roasteries').delete().eq('id', id);
  }
}
