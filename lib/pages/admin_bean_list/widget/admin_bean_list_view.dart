import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/sticky_search_filter.dart';
import '../bloc/admin_bean_list_bloc.dart';
import '../bloc/admin_bean_list_event.dart';
import '../bloc/admin_bean_list_state.dart';
import 'scraper_input.dart';
import 'admin_bean_card.dart';

enum BeanStatusFilter { all, published, draft, unpublished }

class AdminBeanListView extends StatefulWidget {
  final String roasteryId;

  const AdminBeanListView({super.key, required this.roasteryId});

  @override
  State<AdminBeanListView> createState() => _AdminBeanListViewState();
}

class _AdminBeanListViewState extends State<AdminBeanListView> {
  final TextEditingController _searchController = TextEditingController();
  BeanStatusFilter _activeFilter = BeanStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AdminBeanListBloc, AdminBeanListState>(
      builder: (context, state) {
        final filtered = state.filteredBeans;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Beans'),
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                  onPressed: () => context.pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: ScraperInput(roasteryId: widget.roasteryId),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: StickySearchFilter<BeanStatusFilter>(
                  searchController: _searchController,
                  searchHint: 'Search beans...',
                  activeFilter: _activeFilter,
                  filters: const [
                    FilterOption(label: 'All', value: BeanStatusFilter.all),
                    FilterOption(label: 'Published', value: BeanStatusFilter.published),
                    FilterOption(label: 'Draft', value: BeanStatusFilter.draft),
                    FilterOption(label: 'Unpublished', value: BeanStatusFilter.unpublished),
                  ],
                  onFilterChanged: (f) {
                    setState(() => _activeFilter = f);
                    context.read<AdminBeanListBloc>().add(FilterBeans(f.name));
                  },
                  onSearchChanged: (q) {
                    context.read<AdminBeanListBloc>().add(SearchBeans(q));
                  },
                  resultCount: filtered.length,
                ),
              ),

              // ── Content ──
              if (state.status == AdminBeanListStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == AdminBeanListStatus.error)
                SliverFillRemaining(
                  child: _buildErrorState(context, state.errorMessage),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final bean = filtered[index];
                      final isUnpublished = bean.status == 'unpublished';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Opacity(
                          opacity: isUnpublished ? 0.8 : 1.0,
                          child: AdminBeanCard(
                            title: bean.cleanName,
                            price: bean.displayPrice,
                            imageUrl: bean.imageUrl ?? '',
                            status: bean.status,
                            onTap: () {
                              context.push(
                                '/admin/roastery/${widget.roasteryId}/beans/${bean.id}',
                              );
                            },
                          ),
                        ),
                      );
                    }, childCount: filtered.length),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.push('/admin/roastery/${widget.roasteryId}/beans/new');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No beans found',
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the scraper to add beans or tap +',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load beans',
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message ?? 'Unknown error',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {
              context.read<AdminBeanListBloc>().add(LoadBeans(widget.roasteryId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
