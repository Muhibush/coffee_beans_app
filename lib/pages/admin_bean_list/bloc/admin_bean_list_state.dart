import 'package:equatable/equatable.dart';
import '../../../model/bean_model.dart';
import '../../../model/scraped_bean_model.dart';

enum AdminBeanListStatus { initial, loading, loaded, error }

enum ScraperStatus {
  idle,
  inspecting, // Calling /inspect
  selecting, // Bulk mode: User is selecting from discovered products
  scraping, // Actively scraping (single or bulk items)
  success,
  error
}

enum AdminBeanSortOption {
  name,
  createdAt,
  updatedAt,
}

class AdminBeanListState extends Equatable {
  final AdminBeanListStatus status;
  final ScraperStatus scraperStatus;
  final List<Bean> allBeans;
  final List<Bean> filteredBeans;
  final String searchQuery;
  final String activeFilter; // 'all', 'published', 'draft', 'unpublished'
  final AdminBeanSortOption sortBy;
  final bool sortAscending;
  final String? errorMessage;
  final String? scraperError;
  final ScrapedBean? scrapedResult;
  final List<ScraperProduct> discoveredProducts;
  final String? scraperMessage;
  final Set<String> selectedIds;
  final Set<String> sessionAddedIds; // Tracks beans newly created during this session
  final Set<String> sessionUpdatedIds; // Tracks beans updated during this session
  final Set<String> selectedDiscoveredUrls; // Selection in the wizard bulk list

  const AdminBeanListState({
    this.status = AdminBeanListStatus.initial,
    this.scraperStatus = ScraperStatus.idle,
    this.allBeans = const [],
    this.filteredBeans = const [],
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.sortBy = AdminBeanSortOption.updatedAt,
    this.sortAscending = false,
    this.errorMessage,
    this.scraperError,
    this.scrapedResult,
    this.discoveredProducts = const [],
    this.scraperMessage,
    this.selectedIds = const {},
    this.sessionAddedIds = const {},
    this.sessionUpdatedIds = const {},
    this.selectedDiscoveredUrls = const {},
  });

  int get publishedCount => allBeans.where((b) => b.status == 'published').length;
  int get draftCount => allBeans.where((b) => b.status == 'draft').length;
  bool get isSelectionMode => selectedIds.isNotEmpty;

  AdminBeanListState copyWith({
    AdminBeanListStatus? status,
    ScraperStatus? scraperStatus,
    List<Bean>? allBeans,
    List<Bean>? filteredBeans,
    String? searchQuery,
    String? activeFilter,
    AdminBeanSortOption? sortBy,
    bool? sortAscending,
    String? errorMessage,
    String? scraperError,
    ScrapedBean? scrapedResult,
    List<ScraperProduct>? discoveredProducts,
    String? scraperMessage,
    Set<String>? selectedIds,
    Set<String>? sessionAddedIds,
    Set<String>? sessionUpdatedIds,
    Set<String>? selectedDiscoveredUrls,
  }) {
    return AdminBeanListState(
      status: status ?? this.status,
      scraperStatus: scraperStatus ?? this.scraperStatus,
      allBeans: allBeans ?? this.allBeans,
      filteredBeans: filteredBeans ?? this.filteredBeans,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      errorMessage: errorMessage,
      scraperError: scraperError,
      scrapedResult: scrapedResult,
      discoveredProducts: discoveredProducts ?? this.discoveredProducts,
      scraperMessage: scraperMessage,
      selectedIds: selectedIds ?? this.selectedIds,
      sessionAddedIds: sessionAddedIds ?? this.sessionAddedIds,
      sessionUpdatedIds: sessionUpdatedIds ?? this.sessionUpdatedIds,
      selectedDiscoveredUrls: selectedDiscoveredUrls ?? this.selectedDiscoveredUrls,
    );
  }

  @override
  List<Object?> get props => [
        status,
        scraperStatus,
        allBeans,
        filteredBeans,
        searchQuery,
        activeFilter,
        sortBy,
        sortAscending,
        errorMessage,
        scraperError,
        scrapedResult,
        discoveredProducts,
        scraperMessage,
        selectedIds,
        sessionAddedIds,
        sessionUpdatedIds,
        selectedDiscoveredUrls,
      ];
}
