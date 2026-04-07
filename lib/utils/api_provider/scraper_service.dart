import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../model/scraped_bean_model.dart';

/// HTTP client for communicating with the Go scraper service.
/// Handles both single product scraping and bulk URL extraction.
class ScraperService {
  late final Dio _dio;

  ScraperService() {
    final baseUrl = dotenv.env['SCRAPER_BASE_URL'] ?? 'http://localhost:8080';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 120), // Scraping can be slow
      headers: {'Content-Type': 'application/json'},
    ));
  }

  /// Scrape a single product URL → returns normalized [ScrapedBean].
  Future<ScrapedBean> scrapeProduct(String url) async {
    try {
      final response = await _dio.post('/scrape', data: {'url': url});
      final body = response.data as Map<String, dynamic>;

      if (body['success'] == true && body['data'] != null) {
        return ScrapedBean.fromJson(body['data'] as Map<String, dynamic>);
      }
      throw Exception(body['error'] ?? 'Unknown scraper error');
    } on DioException catch (e) {
      throw Exception('Scraper request failed: ${e.message}');
    }
  }

  /// Bulk scrape a store URL → returns list of product URLs.
  Future<List<String>> scrapeBulk(String url, {int? maxProducts}) async {
    try {
      final data = <String, dynamic>{'url': url};
      if (maxProducts != null) data['max_products'] = maxProducts;

      final response = await _dio.post('/scrape-bulk', data: data);
      final body = response.data as Map<String, dynamic>;

      if (body['success'] == true && body['urls'] != null) {
        return (body['urls'] as List).cast<String>();
      }
      throw Exception(body['error'] ?? 'Unknown bulk scraper error');
    } on DioException catch (e) {
      throw Exception('Bulk scraper request failed: ${e.message}');
    }
  }

  /// Health check for the scraper service.
  Future<bool> isHealthy() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
