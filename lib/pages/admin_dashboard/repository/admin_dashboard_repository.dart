import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/roastery.dart';
import '../../../utils/api_provider/supabase_client.dart';

/// Repository for admin dashboard operations.
/// Fetches roasteries from Supabase with bean count aggregation.
class AdminDashboardRepository {
  final SupabaseClient _client;

  AdminDashboardRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  /// Fetches all roasteries with their bean counts.
  /// Uses a separate count query since Supabase REST doesn't support
  /// aggregate COUNT in a single select easily.
  Future<List<Roastery>> fetchRoasteries() async {
    final response = await _client
        .from('roasteries')
        .select()
        .order('created_at', ascending: false);

    final roasteries = (response as List)
        .map((json) => Roastery.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch bean counts for each roastery
    return await _attachBeanCounts(roasteries);
  }

  /// Searches roasteries by name or city.
  Future<List<Roastery>> searchRoasteries(String query) async {
    final response = await _client
        .from('roasteries')
        .select()
        .or('name.ilike.%$query%,city.ilike.%$query%')
        .order('created_at', ascending: false);

    final roasteries = (response as List)
        .map((json) => Roastery.fromJson(json as Map<String, dynamic>))
        .toList();

    return await _attachBeanCounts(roasteries);
  }

  /// Fetches bean count per roastery and attaches it to the model.
  Future<List<Roastery>> _attachBeanCounts(List<Roastery> roasteries) async {
    if (roasteries.isEmpty) return roasteries;

    // Get bean counts grouped by roastery_id
    final countsResponse = await _client
        .from('beans')
        .select('roastery_id')
        .order('roastery_id');

    // Count beans per roastery manually
    final beanCountMap = <String, int>{};
    for (final row in countsResponse as List) {
      final rid = row['roastery_id'] as String;
      beanCountMap[rid] = (beanCountMap[rid] ?? 0) + 1;
    }

    return roasteries.map((r) {
      return r.copyWith(beanCount: beanCountMap[r.id] ?? 0);
    }).toList();
  }
}
