import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/bean_model.dart';
import '../../../model/scraped_bean_model.dart';
import '../../../utils/api_provider/supabase_client.dart';

/// Repository for admin bean list operations.
class AdminBeanListRepository {
  final SupabaseClient _client;

  AdminBeanListRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientProvider.client;

  /// Fetches all beans for a given roastery.
  Future<List<Bean>> fetchBeans(String roasteryId) async {
    final response = await _client
        .from('beans')
        .select()
        .eq('roastery_id', roasteryId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Bean.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Updates the status of a single bean.
  Future<void> updateBeanStatus(String beanId, String status) async {
    await _client
        .from('beans')
        .update({'status': status})
        .eq('id', beanId);
  }

  /// Bulk update status for multiple beans using a single query.
  Future<void> bulkUpdateStatus(List<String> beanIds, String status) async {
    if (beanIds.isEmpty) return;
    await _client
        .from('beans')
        .update({'status': status})
        .inFilter('id', beanIds);
  }

  /// Deletes a bean by id.
  Future<void> deleteBean(String beanId) async {
    await _client.from('beans').delete().eq('id', beanId);
  }

  /// Bulk delete beans by ids.
  Future<void> bulkDelete(List<String> beanIds) async {
    if (beanIds.isEmpty) return;
    await _client.from('beans').delete().inFilter('id', beanIds);
  }

  /// Converts a ScrapedBean into a Bean row and inserts it as 'draft'.
  /// IMPLEMENTS DEEP-MERGE: Merges new variants with existing ones if the bean exists.
  Future<Bean> insertScrapedBean(String roasteryId, ScrapedBean scraped) async {
    final fingerprint = '${roasteryId}_${_slugify(scraped.cleanName)}';

    // 1. Check for existing bean
    final existingResponse = await _client
        .from('beans')
        .select()
        .eq('fingerprint', fingerprint)
        .maybeSingle();

    Map<int, BeanVariant> mergedVariants = {};

    if (existingResponse != null) {
      final existingBean = Bean.fromJson(existingResponse);
      mergedVariants.addAll(existingBean.variants);
    }

    // 2. Map ScrapedVariants to BeanVariants and merge
    final newVariants = scraped.variants.map((key, sv) => MapEntry(
          key,
          BeanVariant(
            price: sv.price,
            buyUrl: sv.buyUrl,
            marketplace: sv.marketplace,
          ),
        ));

    mergedVariants.addAll(newVariants);

    final bean = Bean(
      id: existingResponse != null ? existingResponse['id'] as String : '',
      roasteryId: roasteryId,
      cleanName: scraped.cleanName,
      fingerprint: fingerprint,
      variety: scraped.variety,
      notes: scraped.notes,
      process: scraped.process,
      roastLevel: scraped.roastLevel,
      status: 'draft',
      variants: mergedVariants,
      imageUrl: scraped.imageUrl,
      origin: scraped.origin,
      altitude: scraped.altitude,
      description: scraped.description,
    );

    final response = await _client
        .from('beans')
        .upsert(bean.toJson(), onConflict: 'fingerprint')
        .select()
        .single();

    return Bean.fromJson(response);
  }

  String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
