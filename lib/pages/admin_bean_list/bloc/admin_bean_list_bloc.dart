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
  }

  Future<void> _onLoadBeans(
    LoadBeans event,
    Emitter<AdminBeanListState> emit,
  ) async {
    _roasteryId = event.roasteryId;
    emit(state.copyWith(status: AdminBeanListStatus.loading));
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
      emit(state.copyWith(allBeans: updated));
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete: ${e.toString()}'));
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
