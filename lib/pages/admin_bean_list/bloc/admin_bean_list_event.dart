import 'package:equatable/equatable.dart';
import '../../../model/scraped_bean_model.dart';

abstract class AdminBeanListEvent extends Equatable {
  const AdminBeanListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all beans for a roastery.
class LoadBeans extends AdminBeanListEvent {
  final String roasteryId;
  const LoadBeans(this.roasteryId);

  @override
  List<Object?> get props => [roasteryId];
}

/// Search beans by name.
class SearchBeans extends AdminBeanListEvent {
  final String query;
  const SearchBeans(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter beans by status.
class FilterBeans extends AdminBeanListEvent {
  final String filter; // 'all', 'published', 'draft', 'unpublished'
  const FilterBeans(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Scrape a single product URL.
class ScrapeUrl extends AdminBeanListEvent {
  final String url;
  final String roasteryId;
  const ScrapeUrl({required this.url, required this.roasteryId});

  @override
  List<Object?> get props => [url, roasteryId];
}

/// Save a scraped bean to the database.
class SaveScrapedBean extends AdminBeanListEvent {
  final String roasteryId;
  final ScrapedBean scrapedBean;
  const SaveScrapedBean({required this.roasteryId, required this.scrapedBean});

  @override
  List<Object?> get props => [roasteryId, scrapedBean];
}

/// Update a bean's status.
class UpdateBeanStatus extends AdminBeanListEvent {
  final String beanId;
  final String status;
  const UpdateBeanStatus({required this.beanId, required this.status});

  @override
  List<Object?> get props => [beanId, status];
}

/// Delete a bean.
class DeleteBeanFromList extends AdminBeanListEvent {
  final String beanId;
  const DeleteBeanFromList(this.beanId);

  @override
  List<Object?> get props => [beanId];
}
