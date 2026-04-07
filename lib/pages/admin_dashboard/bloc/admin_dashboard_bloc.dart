import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/roastery.dart';
import '../repository/admin_dashboard_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminDashboardRepository repository;

  AdminDashboardBloc({required this.repository})
      : super(const AdminDashboardState()) {
    on<LoadRoasteries>(_onLoadRoasteries);
    on<SearchRoasteries>(_onSearchRoasteries);
    on<FilterRoasteries>(_onFilterRoasteries);
  }

  Future<void> _onLoadRoasteries(
    LoadRoasteries event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(state.copyWith(status: AdminDashboardStatus.loading));
    try {
      final roasteries = await repository.fetchRoasteries();
      emit(state.copyWith(
        status: AdminDashboardStatus.loaded,
        allRoasteries: roasteries,
        filteredRoasteries: roasteries,
        searchQuery: '',
        activeFilter: 'all',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchRoasteries(
    SearchRoasteries event,
    Emitter<AdminDashboardState> emit,
  ) async {
    final query = event.query;
    emit(state.copyWith(searchQuery: query));
    _applyFilters(emit);
  }

  void _onFilterRoasteries(
    FilterRoasteries event,
    Emitter<AdminDashboardState> emit,
  ) {
    emit(state.copyWith(activeFilter: event.filter));
    _applyFilters(emit);
  }

  void _applyFilters(Emitter<AdminDashboardState> emit) {
    var filtered = List<Roastery>.from(state.allRoasteries);

    // Apply status filter
    if (state.activeFilter == 'active') {
      filtered = filtered.where((r) => r.isActive).toList();
    } else if (state.activeFilter == 'inactive') {
      filtered = filtered.where((r) => !r.isActive).toList();
    }

    // Apply search query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.city.toLowerCase().contains(query);
      }).toList();
    }

    emit(state.copyWith(filteredRoasteries: filtered));
  }
}
