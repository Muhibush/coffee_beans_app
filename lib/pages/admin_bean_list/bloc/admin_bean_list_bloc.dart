import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/bean_model.dart';
import '../../../utils/api_provider/scraper_service.dart';
import '../repository/admin_bean_list_repository.dart';
import 'admin_bean_list_event.dart';
import 'admin_bean_list_state.dart';

class AdminBeanListBloc extends Bloc<AdminBeanListEvent, AdminBeanListState> {
  final AdminBeanListRepository repository;
  final ScraperService scraperService;
  String? _roasteryId;

  AdminBeanListBloc({
    required this.repository,
    required this.scraperService,
  }) : super(const AdminBeanListState()) {
    on<LoadBeans>(_onLoadBeans);
    on<SearchBeans>(_onSearchBeans);
    on<FilterBeans>(_onFilterBeans);
    on<ScrapeUrl>(_onScrapeUrl);
    on<SaveScrapedBean>(_onSaveScrapedBean);
    on<UpdateBeanStatus>(_onUpdateBeanStatus);
    on<DeleteBeanFromList>(_onDeleteBean);
    on<ScrapeBulkUrl>(_onScrapeBulkUrl);

    // Selection Events
    on<ToggleSelectBean>(_onToggleSelect);
    on<SelectAllBeans>(_onSelectAll);
    on<ClearSelection>(_onClearSelection);
    on<BulkUpdateStatus>(_onBulkUpdateStatus);
    on<BulkDeleteBeans>(_onBulkDelete);
  }

  Future<void> _onLoadBeans(
    LoadBeans event,
    Emitter<AdminBeanListState> emit,
  ) async {
    _roasteryId = event.roasteryId;
    emit(state.copyWith(
      status: AdminBeanListStatus.loading,
      selectedIds: {}, // Clear selection on reload
    ));
    try {
      final beans = await repository.fetchBeans(event.roasteryId);
      emit(state.copyWith(
        status: AdminBeanListStatus.loaded,
        allBeans: beans,
        filteredBeans: beans,
        searchQuery: '',
        activeFilter: 'all',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchBeans(
    SearchBeans event,
    Emitter<AdminBeanListState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onFilterBeans(
    FilterBeans event,
    Emitter<AdminBeanListState> emit,
  ) {
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
      await repository.insertScrapedBean(
        event.roasteryId,
        scraped,
      );
      // Reload the full list
      final beans = await repository.fetchBeans(event.roasteryId);
      emit(state.copyWith(
        scraperStatus: ScraperStatus.success,
        scrapedResult: scraped,
        allBeans: beans,
        filteredBeans: beans,
      ));
    } catch (e) {
      emit(state.copyWith(
        scraperStatus: ScraperStatus.error,
        scraperError: e.toString(),
      ));
    }
  }

  Future<void> _onScrapeBulkUrl(
    ScrapeBulkUrl event,
    Emitter<AdminBeanListState> emit,
  ) async {
    emit(state.copyWith(
      scraperStatus: ScraperStatus.scraping,
      scraperMessage: 'Extracting product URLs...',
    ));

    try {
      final urls = await scraperService.scrapeBulk(
        event.url,
        maxProducts: event.maxProducts > 0 ? event.maxProducts : null,
      );

      if (urls.isEmpty) {
        emit(state.copyWith(
          scraperStatus: ScraperStatus.error,
          scraperError: 'No product URLs found at this location.',
        ));
        return;
      }

      int successCount = 0;
      int errorCount = 0;
      int skippedCount = 0;

      // Map existing beans by fingerprint for quick lookup
      final currentBeans = await repository.fetchBeans(event.roasteryId);
      final existingFingerprints =
          currentBeans.map((b) => b.fingerprint).toSet();

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        emit(state.copyWith(
          scraperMessage: 'Scraping ${i + 1}/${urls.length}: $url',
        ));

        try {
          final scraped = await scraperService.scrapeProduct(url);
          final slug = scraped.cleanName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-|-$'), '');
          final fingerprint = '${event.roasteryId}_$slug';

          // Apply Scope Filtering
          bool shouldSave = true;
          if (event.scope == BulkScrapeScope.newOnly &&
              existingFingerprints.contains(fingerprint)) {
            shouldSave = false;
            skippedCount++;
          } else if (event.scope == BulkScrapeScope.updateOnly &&
              !existingFingerprints.contains(fingerprint)) {
            shouldSave = false;
            skippedCount++;
          }

          if (shouldSave) {
            await repository.insertScrapedBean(event.roasteryId, scraped);
            successCount++;
          }
        } catch (e) {
          errorCount++;
          // Log error but continue bulk process
          debugPrint('Error scraping bulk item $url: $e');
        }
      }

      // Reload list
      if (_roasteryId != null) {
        final beans = await repository.fetchBeans(_roasteryId!);
        emit(state.copyWith(
          scraperStatus: ScraperStatus.success,
          scraperMessage:
              'Bulk scrape complete: $successCount saved, $skippedCount skipped, $errorCount errors.',
          allBeans: beans,
          filteredBeans: beans,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        scraperStatus: ScraperStatus.error,
        scraperError: 'Bulk scrape failed: ${e.toString()}',
      ));
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
        emit(state.copyWith(
          allBeans: beans,
          filteredBeans: beans,
          scraperStatus: ScraperStatus.idle,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        scraperStatus: ScraperStatus.error,
        scraperError: e.toString(),
      ));
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
      emit(state.copyWith(
        errorMessage: 'Failed to update status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteBean(
    DeleteBeanFromList event,
    Emitter<AdminBeanListState> emit,
  ) async {
    try {
      await repository.deleteBean(event.beanId);
      final updated = state.allBeans.where((b) => b.id != event.beanId).toList();
      emit(state.copyWith(
        allBeans: updated,
        selectedIds: Set.from(state.selectedIds)..remove(event.beanId),
      ));
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete: ${e.toString()}'));
    }
  }

  // --- Selection Handlers ---

  void _onToggleSelect(ToggleSelectBean event, Emitter<AdminBeanListState> emit) {
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

  void _onClearSelection(ClearSelection event, Emitter<AdminBeanListState> emit) {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> _onBulkUpdateStatus(BulkUpdateStatus event, Emitter<AdminBeanListState> emit) async {
    if (state.selectedIds.isEmpty) return;
    
    emit(state.copyWith(status: AdminBeanListStatus.loading));
    try {
      await repository.bulkUpdateStatus(state.selectedIds.toList(), event.status);
      
      // Update local state
      final updated = state.allBeans.map((b) {
        if (state.selectedIds.contains(b.id)) {
          return b.copyWith(status: event.status);
        }
        return b;
      }).toList();
      
      emit(state.copyWith(
        status: AdminBeanListStatus.loaded,
        allBeans: updated,
        selectedIds: {}, // Clear selection after success
      ));
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanListStatus.error,
        errorMessage: 'Bulk update failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBulkDelete(BulkDeleteBeans event, Emitter<AdminBeanListState> emit) async {
    if (state.selectedIds.isEmpty) return;
    
    emit(state.copyWith(status: AdminBeanListStatus.loading));
    try {
      await repository.bulkDelete(state.selectedIds.toList());
      
      final updated = state.allBeans.where((b) => !state.selectedIds.contains(b.id)).toList();
      
      emit(state.copyWith(
        status: AdminBeanListStatus.loaded,
        allBeans: updated,
        selectedIds: {},
      ));
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanListStatus.error,
        errorMessage: 'Bulk delete failed: ${e.toString()}',
      ));
    }
  }

  void _applyFilters(Emitter<AdminBeanListState> emit) {
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

    emit(state.copyWith(filteredBeans: filtered));
  }
}
