import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/bean_model.dart';
import '../../../model/scraped_bean_model.dart';
import '../../../utils/api_provider/scraper_service.dart';
import '../repository/admin_bean_list_repository.dart';
import 'admin_bean_list_event.dart';
import 'admin_bean_list_state.dart';

class AdminBeanListBloc extends Bloc<AdminBeanListEvent, AdminBeanListState> {
  final AdminBeanListRepository repository;
  final ScraperService scraperService;
  String? _roasteryId;

  AdminBeanListBloc({required this.repository, required this.scraperService})
    : super(const AdminBeanListState()) {
    on<LoadBeans>(_onLoadBeans);
    on<SearchBeans>(_onSearchBeans);
    on<FilterBeans>(_onFilterBeans);
    on<ChangeSortOption>(_onChangeSortOption);
    on<ScrapeUrl>(_onScrapeUrl);
    on<SaveScrapedBean>(_onSaveScrapedBean);
    on<UpdateBeanStatus>(_onUpdateBeanStatus);
    on<DeleteBeanFromList>(_onDeleteBean);

    // Selection Events
    on<ToggleSelectBean>(_onToggleSelect);
    on<SelectAllBeans>(_onSelectAll);
    on<ClearSelection>(_onClearSelection);
    on<BulkUpdateStatus>(_onBulkUpdateStatus);
    on<BulkDeleteBeans>(_onBulkDelete);

    // Wizard Events
    on<StartScraperWizard>(_onStartScraperWizard);
    on<ToggleScraperProductSelection>(_onToggleScraperProductSelection);
    on<ConfirmBulkScrape>(_onConfirmBulkScrape);
    on<CancelScraperWizard>(_onCancelScraperWizard);
    on<ChangeScraperScope>(_onChangeScraperScope);
  }

  Future<void> _onStartScraperWizard(
    StartScraperWizard event,
    Emitter<AdminBeanListState> emit,
  ) async {
    emit(
      state.copyWith(
        scraperStatus: ScraperStatus.inspecting,
        scraperError: null,
        discoveredProducts: [],
        selectedDiscoveredUrls: {},
      ),
    );

    try {
      if (event.isBulk) {
        // Bulk -> Fetch preview products for selection
        emit(
          state.copyWith(
            scraperStatus: ScraperStatus.inspecting,
            scraperMessage: 'Analyzing store...',
          ),
        );

        final products = await scraperService.scrapeBulk(
          event.url,
          maxProducts: event.maxProducts,
        );

        emit(
          state.copyWith(
            scraperStatus: ScraperStatus.selecting,
            discoveredProducts: products,
            selectedDiscoveredUrls: products
                .map((p) => p.url)
                .toSet(), // Default select all
          ),
        );
      } else {
        // Single product -> Go straight to scraping
        add(ScrapeUrl(url: event.url, roasteryId: event.roasteryId));
      }
    } catch (e) {
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: e.toString(),
        ),
      );
    }
  }

  void _onToggleScraperProductSelection(
    ToggleScraperProductSelection event,
    Emitter<AdminBeanListState> emit,
  ) {
    final newSelection = Set<String>.from(state.selectedDiscoveredUrls);
    if (newSelection.contains(event.product.url)) {
      newSelection.remove(event.product.url);
    } else {
      newSelection.add(event.product.url);
    }
    emit(state.copyWith(selectedDiscoveredUrls: newSelection));
  }

  void _onChangeScraperScope(
    ChangeScraperScope event,
    Emitter<AdminBeanListState> emit,
  ) {
    Set<String> newSelection = {};
    if (event.scope == BulkScrapeScope.all) {
      newSelection = state.discoveredProducts.map((p) => p.url).toSet();
    } else if (event.scope == BulkScrapeScope.none) {
      newSelection = {};
    } else {
      final existingUrls = state.allBeans
          .expand((b) => b.variants.values.map((v) => v.buyUrl))
          .toSet();

      for (var product in state.discoveredProducts) {
        final exists = existingUrls.contains(product.url);
        if (event.scope == BulkScrapeScope.newOnly && !exists) {
          newSelection.add(product.url);
        } else if (event.scope == BulkScrapeScope.updateOnly && exists) {
          newSelection.add(product.url);
        }
      }
    }
    emit(state.copyWith(selectedDiscoveredUrls: newSelection));
  }

  Future<void> _onConfirmBulkScrape(
    ConfirmBulkScrape event,
    Emitter<AdminBeanListState> emit,
  ) async {
    // Collect the URLs to scrape from the selection
    final urlsToScrape = state.discoveredProducts
        .where((p) => state.selectedDiscoveredUrls.contains(p.url))
        .map((p) => p.url)
        .toList();

    if (urlsToScrape.isEmpty) {
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: 'Please select at least one item.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        scraperStatus: ScraperStatus.scraping,
        scraperMessage: 'Preparing to scrape ${urlsToScrape.length} items...',
      ),
    );

    try {
      int successCount = 0;
      int errorCount = 0;
      int skippedCount = 0;
      final sessionAddedIds = <String>{};
      final sessionUpdatedIds = <String>{};

      // Build registries for fast lookup and skipping
      final currentBeans = await repository.fetchBeans(event.roasteryId);
      final existingFingerprints = currentBeans
          .map((b) => b.fingerprint)
          .toSet();
      final existingUrls = currentBeans
          .expand((b) => b.variants.values.map((v) => v.buyUrl))
          .toSet();

      for (int i = 0; i < urlsToScrape.length; i++) {
        final url = urlsToScrape[i];

        // 1. Pre-scrape Scope Filtering
        if (event.scope == BulkScrapeScope.newOnly &&
            existingUrls.contains(url)) {
          skippedCount++;
          continue;
        }

        if (event.scope == BulkScrapeScope.updateOnly &&
            !existingUrls.contains(url)) {
          skippedCount++;
          continue;
        }

        final productTitle = state.discoveredProducts
            .firstWhere(
              (p) => p.url == url,
              orElse: () => const ScraperProduct(url: '', title: 'Unknown'),
            )
            .title;

        emit(
          state.copyWith(
            scraperMessage: '${i + 1}/${urlsToScrape.length} : $productTitle',
          ),
        );

        try {
          final scraped = await scraperService.scrapeProduct(url);
          final slug = scraped.cleanName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-|-$'), '');
          final fingerprint = '${event.roasteryId}_$slug';

          // 2. Post-scrape Scope Filtering
          final isExisting = existingFingerprints.contains(fingerprint);
          if (event.scope == BulkScrapeScope.newOnly && isExisting) {
            skippedCount++;
            continue;
          }

          final bean = await repository.insertScrapedBean(
            event.roasteryId,
            scraped,
          );
          if (isExisting) {
            sessionUpdatedIds.add(bean.id);
          } else {
            sessionAddedIds.add(bean.id);
          }
          successCount++;
        } catch (e) {
          errorCount++;
          debugPrint('Error scraping item $url: $e');
        }
      }

      // Reload full list
      final beans = await repository.fetchBeans(event.roasteryId);
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.success,
          scraperMessage:
              'Success: $successCount saved, $skippedCount skipped, $errorCount errors.',
          allBeans: beans,
          filteredBeans: beans,
          sessionAddedIds: {...state.sessionAddedIds, ...sessionAddedIds},
          sessionUpdatedIds: {...state.sessionUpdatedIds, ...sessionUpdatedIds},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: e.toString(),
        ),
      );
    }
  }

  void _onCancelScraperWizard(
    CancelScraperWizard event,
    Emitter<AdminBeanListState> emit,
  ) {
    emit(
      state.copyWith(
        scraperStatus: ScraperStatus.idle,
        discoveredProducts: [],
        selectedDiscoveredUrls: {},
        scraperError: null,
      ),
    );
  }

  Future<void> _onLoadBeans(
    LoadBeans event,
    Emitter<AdminBeanListState> emit,
  ) async {
    _roasteryId = event.roasteryId;
    emit(
      state.copyWith(
        status: AdminBeanListStatus.loading,
        selectedIds: {}, // Clear selection on reload
      ),
    );
    try {
      final beans = await repository.fetchBeans(event.roasteryId);
      emit(
        state.copyWith(
          status: AdminBeanListStatus.loaded,
          allBeans: beans,
          filteredBeans: beans,
          searchQuery: '',
          activeFilter: 'all',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminBeanListStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchBeans(SearchBeans event, Emitter<AdminBeanListState> emit) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onFilterBeans(FilterBeans event, Emitter<AdminBeanListState> emit) {
    emit(state.copyWith(activeFilter: event.filter));
    _applyFilters(emit);
  }

  Future<void> _onScrapeUrl(
    ScrapeUrl event,
    Emitter<AdminBeanListState> emit,
  ) async {
    emit(state.copyWith(scraperStatus: ScraperStatus.scraping));
    try {
      final scraped = await scraperService.scrapeProduct(event.url);
      // Auto-save to DB as draft
      await repository.insertScrapedBean(event.roasteryId, scraped);
      // Reload the full list
      final beans = await repository.fetchBeans(event.roasteryId);
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.success,
          scrapedResult: scraped,
          allBeans: beans,
          filteredBeans: beans,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveScrapedBean(
    SaveScrapedBean event,
    Emitter<AdminBeanListState> emit,
  ) async {
    try {
      await repository.insertScrapedBean(event.roasteryId, event.scrapedBean);
      if (_roasteryId != null) {
        final beans = await repository.fetchBeans(_roasteryId!);
        emit(
          state.copyWith(
            allBeans: beans,
            filteredBeans: beans,
            scraperStatus: ScraperStatus.idle,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateBeanStatus(
    UpdateBeanStatus event,
    Emitter<AdminBeanListState> emit,
  ) async {
    try {
      await repository.updateBeanStatus(event.beanId, event.status);
      // Update local state
      final updated = state.allBeans.map((b) {
        if (b.id == event.beanId) return b.copyWith(status: event.status);
        return b;
      }).toList();
      emit(state.copyWith(allBeans: updated));
      _applyFilters(emit);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update status: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeleteBean(
    DeleteBeanFromList event,
    Emitter<AdminBeanListState> emit,
  ) async {
    try {
      await repository.deleteBean(event.beanId);
      final updated = state.allBeans
          .where((b) => b.id != event.beanId)
          .toList();
      emit(
        state.copyWith(
          allBeans: updated,
          selectedIds: Set.from(state.selectedIds)..remove(event.beanId),
        ),
      );
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete: ${e.toString()}'));
    }
  }

  // --- Selection Handlers ---

  void _onToggleSelect(
    ToggleSelectBean event,
    Emitter<AdminBeanListState> emit,
  ) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(event.id)) {
      newSelected.remove(event.id);
    } else {
      newSelected.add(event.id);
    }
    emit(state.copyWith(selectedIds: newSelected));
  }

  void _onSelectAll(SelectAllBeans event, Emitter<AdminBeanListState> emit) {
    final allIds = state.filteredBeans.map((b) => b.id).toSet();
    emit(state.copyWith(selectedIds: allIds));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<AdminBeanListState> emit,
  ) {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> _onBulkUpdateStatus(
    BulkUpdateStatus event,
    Emitter<AdminBeanListState> emit,
  ) async {
    if (state.selectedIds.isEmpty) return;

    emit(state.copyWith(status: AdminBeanListStatus.loading));
    try {
      await repository.bulkUpdateStatus(
        state.selectedIds.toList(),
        event.status,
      );

      // Update local state
      final updated = state.allBeans.map((b) {
        if (state.selectedIds.contains(b.id)) {
          return b.copyWith(status: event.status);
        }
        return b;
      }).toList();

      emit(
        state.copyWith(
          status: AdminBeanListStatus.loaded,
          allBeans: updated,
          selectedIds: {}, // Clear selection after success
        ),
      );
      _applyFilters(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminBeanListStatus.error,
          errorMessage: 'Bulk update failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onBulkDelete(
    BulkDeleteBeans event,
    Emitter<AdminBeanListState> emit,
  ) async {
    if (state.selectedIds.isEmpty) return;

    emit(state.copyWith(status: AdminBeanListStatus.loading));
    try {
      await repository.bulkDelete(state.selectedIds.toList());

      final updated = state.allBeans
          .where((b) => !state.selectedIds.contains(b.id))
          .toList();

      emit(
        state.copyWith(
          status: AdminBeanListStatus.loaded,
          allBeans: updated,
          selectedIds: {},
        ),
      );
      _applyFilters(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminBeanListStatus.error,
          errorMessage: 'Bulk delete failed: ${e.toString()}',
        ),
      );
    }
  }

  void _onChangeSortOption(
    ChangeSortOption event,
    Emitter<AdminBeanListState> emit,
  ) {
    emit(
      state.copyWith(
        sortBy: event.sortOption,
        sortAscending: event.isAscending,
      ),
    );
    // Since sort is updated in state, we must pass the new state fields
    // to apply the sort properly. Re-evaluate against the current emission:
    _applyFilters(
      emit,
      overrideSortBy: event.sortOption,
      overrideAsc: event.isAscending,
    );
  }

  void _applyFilters(
    Emitter<AdminBeanListState> emit, {
    AdminBeanSortOption? overrideSortBy,
    bool? overrideAsc,
  }) {
    var filtered = List<Bean>.from(state.allBeans);

    if (state.activeFilter != 'all') {
      filtered = filtered.where((b) => b.status == state.activeFilter).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        return b.cleanName.toLowerCase().contains(query);
      }).toList();
    }

    final sortBy = overrideSortBy ?? state.sortBy;
    final sortAsc = overrideAsc ?? state.sortAscending;

    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case AdminBeanSortOption.name:
          comparison = a.cleanName.compareTo(b.cleanName);
          break;
        case AdminBeanSortOption.createdAt:
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          comparison = aDate.compareTo(bDate);
          break;
        case AdminBeanSortOption.updatedAt:
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          comparison = aDate.compareTo(bDate);
          break;
      }
      return sortAsc ? comparison : -comparison;
    });

    emit(state.copyWith(filteredBeans: filtered));
  }
}
