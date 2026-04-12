import '../../../model/scraped_bean_model.dart';
import 'admin_bean_list_state.dart';

abstract class AdminBeanListEvent {}

class LoadBeans extends AdminBeanListEvent {
  final String roasteryId;
  LoadBeans(this.roasteryId);
}

class SearchBeans extends AdminBeanListEvent {
  final String query;
  SearchBeans(this.query);
}

class FilterBeans extends AdminBeanListEvent {
  final String filter;
  FilterBeans(this.filter);
}

class ChangeSortOption extends AdminBeanListEvent {
  final AdminBeanSortOption sortOption;
  final bool isAscending;
  ChangeSortOption({
    required this.sortOption,
    required this.isAscending,
  });
}

class ScrapeUrl extends AdminBeanListEvent {
  final String url;
  final String roasteryId;
  ScrapeUrl({required this.url, required this.roasteryId});
}

class SaveScrapedBean extends AdminBeanListEvent {
  final String roasteryId;
  final ScrapedBean scrapedBean;
  SaveScrapedBean({required this.roasteryId, required this.scrapedBean});
}

class UpdateBeanStatus extends AdminBeanListEvent {
  final String beanId;
  final String status;
  UpdateBeanStatus({required this.beanId, required this.status});
}

class DeleteBeanFromList extends AdminBeanListEvent {
  final String beanId;
  DeleteBeanFromList(this.beanId);
}

class ScrapeBulkUrl extends AdminBeanListEvent {
  final String url;
  final String roasteryId;
  final int maxProducts;
  final BulkScrapeScope scope;

  ScrapeBulkUrl({
    required this.url,
    required this.roasteryId,
    this.maxProducts = 0,
    this.scope = BulkScrapeScope.all,
  });
}

enum BulkScrapeScope { all, newOnly, updateOnly, none }

/// --- Selection Events ---

class ToggleSelectBean extends AdminBeanListEvent {
  final String id;
  ToggleSelectBean(this.id);
}

class SelectAllBeans extends AdminBeanListEvent {}

class ClearSelection extends AdminBeanListEvent {}

class BulkUpdateStatus extends AdminBeanListEvent {
  final String status;
  BulkUpdateStatus(this.status);
}

class BulkDeleteBeans extends AdminBeanListEvent {}

/// --- Scraper Wizard Events ---

class StartScraperWizard extends AdminBeanListEvent {
  final String url;
  final String roasteryId;
  final bool isBulk;
  final int? maxProducts;
  StartScraperWizard({
    required this.url,
    required this.roasteryId,
    this.isBulk = false,
    this.maxProducts,
  });
}

class ToggleScraperProductSelection extends AdminBeanListEvent {
  final ScraperProduct product;
  ToggleScraperProductSelection(this.product);
}

class ChangeScraperScope extends AdminBeanListEvent {
  final BulkScrapeScope scope;
  ChangeScraperScope(this.scope);
}

class ConfirmBulkScrape extends AdminBeanListEvent {
  final String roasteryId;
  final BulkScrapeScope scope;
  ConfirmBulkScrape({required this.roasteryId, required this.scope});
}

class CancelScraperWizard extends AdminBeanListEvent {}
