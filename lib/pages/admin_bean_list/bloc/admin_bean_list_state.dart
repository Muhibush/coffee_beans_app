import 'package:equatable/equatable.dart';
import '../../../model/bean_model.dart';
import '../../../model/scraped_bean_model.dart';

enum AdminBeanListStatus { initial, loading, loaded, error }

enum ScraperStatus { idle, scraping, success, error }

class AdminBeanListState extends Equatable {
  final AdminBeanListStatus status;
  final ScraperStatus scraperStatus;
  final List<Bean> allBeans;
  final List<Bean> filteredBeans;
  final String searchQuery;
  final String activeFilter; // 'all', 'published', 'draft', 'unpublished'
  final String? errorMessage;
  final String? scraperError;
  final ScrapedBean? scrapedResult;

  const AdminBeanListState({
    this.status = AdminBeanListStatus.initial,
    this.scraperStatus = ScraperStatus.idle,
    this.allBeans = const [],
    this.filteredBeans = const [],
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.errorMessage,
    this.scraperError,
    this.scrapedResult,
  });

  int get publishedCount => allBeans.where((b) => b.status == 'published').length;
  int get draftCount => allBeans.where((b) => b.status == 'draft').length;

  AdminBeanListState copyWith({
    AdminBeanListStatus? status,
    ScraperStatus? scraperStatus,
    List<Bean>? allBeans,
    List<Bean>? filteredBeans,
    String? searchQuery,
    String? activeFilter,
    String? errorMessage,
    String? scraperError,
    ScrapedBean? scrapedResult,
  }) {
    return AdminBeanListState(
      status: status ?? this.status,
      scraperStatus: scraperStatus ?? this.scraperStatus,
      allBeans: allBeans ?? this.allBeans,
      filteredBeans: filteredBeans ?? this.filteredBeans,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      errorMessage: errorMessage,
      scraperError: scraperError,
      scrapedResult: scrapedResult,
    );
  }

  @override
  List<Object?> get props => [
        status, scraperStatus, allBeans, filteredBeans,
        searchQuery, activeFilter, errorMessage, scraperError, scrapedResult,
      ];
}
