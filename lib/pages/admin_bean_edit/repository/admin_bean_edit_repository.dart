import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/bean_model.dart';
import '../../../utils/api_provider/supabase_client.dart';

/// Repository for admin bean edit CRUD operations.
class AdminBeanEditRepository {
  final SupabaseClient _client;

  AdminBeanEditRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  /// Fetches a single bean by id.
  Future<Bean> getBean(String beanId) async {
    final response = await _client
        .from('beans')
        .select()
        .eq('id', beanId)
        .single();

    return Bean.fromJson(response);
  }

  /// Saves (upserts) a bean to the database.
  Future<Bean> saveBean(Bean bean) async {
    final response = await _client
        .from('beans')
        .upsert(bean.toJson())
        .select()
        .single();

    return Bean.fromJson(response);
  }

  /// Deletes a bean by id.
  Future<void> deleteBean(String beanId) async {
    await _client.from('beans').delete().eq('id', beanId);
  }
}
