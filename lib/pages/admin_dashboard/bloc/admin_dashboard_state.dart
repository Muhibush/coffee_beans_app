import 'package:equatable/equatable.dart';
import '../../../model/roastery.dart';

enum AdminDashboardStatus { initial, loading, loaded, error }

class AdminDashboardState extends Equatable {
  final AdminDashboardStatus status;
  final List<Roastery> allRoasteries;
  final List<Roastery> filteredRoasteries;
  final String searchQuery;
  final String activeFilter; // 'all', 'active', 'inactive'
  final String? errorMessage;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.allRoasteries = const [],
    this.filteredRoasteries = const [],
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.errorMessage,
  });

  int get totalBeans => allRoasteries.fold(0, (sum, r) => sum + r.beanCount);
  int get activeCount => allRoasteries.where((r) => r.isActive).length;

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    List<Roastery>? allRoasteries,
    List<Roastery>? filteredRoasteries,
    String? searchQuery,
    String? activeFilter,
    String? errorMessage,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      allRoasteries: allRoasteries ?? this.allRoasteries,
      filteredRoasteries: filteredRoasteries ?? this.filteredRoasteries,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, allRoasteries, filteredRoasteries,
        searchQuery, activeFilter, errorMessage,
      ];
}
