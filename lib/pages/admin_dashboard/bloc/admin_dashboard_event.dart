import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load all roasteries from Supabase.
class LoadRoasteries extends AdminDashboardEvent {}

/// Search roasteries by query string.
class SearchRoasteries extends AdminDashboardEvent {
  final String query;

  const SearchRoasteries(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter roasteries by active/inactive status.
class FilterRoasteries extends AdminDashboardEvent {
  final String filter; // 'all', 'active', 'inactive'

  const FilterRoasteries(this.filter);

  @override
  List<Object?> get props => [filter];
}
