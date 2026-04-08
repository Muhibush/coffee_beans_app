import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_bean_list_bloc.dart';
import '../bloc/admin_bean_list_event.dart';
import '../bloc/admin_bean_list_state.dart';
import 'scraper_bottom_sheet.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AdminBeanListBloc, AdminBeanListState>(
      builder: (context, state) {
        final filtered = state.filteredBeans;
        final hasSelection = state.isSelectionMode;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: const Text('Beans Catalog'),
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    centerTitle: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.primary, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      if (hasSelection)
                        TextButton(
                          onPressed: () => context.read<AdminBeanListBloc>().add(ClearSelection()),
                          child: Text(
                            'Cancel',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!hasSelection) ...[
                        IconButton(
                          icon: Icon(Icons.bolt_outlined, color: colorScheme.onSurfaceVariant),
                          tooltip: 'Scraper',
                          onPressed: () => _showScraper(context),
                        ),
                        if (filtered.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.checklist_rounded, color: colorScheme.onSurfaceVariant),
                            tooltip: 'Select All',
                            onPressed: () => context.read<AdminBeanListBloc>().add(SelectAllBeans()),
                          ),
                      ],
                      const SizedBox(width: 8),
                    ],
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _AdminBeanStickyHeaderDelegate(
                      searchController: _searchController,
                      onSearchChanged: (q) {
                        context.read<AdminBeanListBloc>().add(SearchBeans(q));
                      },
                      onFilterTap: () => _showFilterSortSheet(context),
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
                      padding: EdgeInsets.fromLTRB(16, 20, 16, hasSelection ? 140 : 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final bean = filtered[index];
                          final isUnpublished = bean.status == 'unpublished';
                          final isSelected = state.selectedIds.contains(bean.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Opacity(
                              opacity: isUnpublished ? 0.8 : 1.0,
                              child: AdminBeanCard(
                                title: bean.cleanName,
                                price: bean.displayPrice,
                                imageUrl: bean.imageUrl ?? '',
                                status: bean.status,
                                isSelectionMode: hasSelection,
                                isSelected: isSelected,
                                onSelectedChanged: (val) {
                                  context.read<AdminBeanListBloc>().add(ToggleSelectBean(bean.id));
                                },
                                onTap: () {
                                  if (hasSelection) {
                                    context.read<AdminBeanListBloc>().add(ToggleSelectBean(bean.id));
                                  } else {
                                    context.push(
                                      '/admin/roastery/${widget.roasteryId}/beans/${bean.id}',
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                ],
              ),
              
              // Bulk Action Bar
              if (hasSelection)
                _buildBulkActionBar(context, state),
            ],
          ),
          floatingActionButton: hasSelection 
              ? null 
              : FloatingActionButton.extended(
                  onPressed: () {
                    context.push('/admin/roastery/${widget.roasteryId}/beans/new');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Bean'),
                ),
        );
      },
    );
  }

  Widget _buildBulkActionBar(BuildContext context, AdminBeanListState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = state.selectedIds.length;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selected',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Actions
                _ActionButton(
                  icon: Icons.publish_rounded,
                  label: 'Pub',
                  onTap: () => context.read<AdminBeanListBloc>().add(BulkUpdateStatus('published')),
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.drafts_outlined,
                  label: 'Draft',
                  onTap: () => context.read<AdminBeanListBloc>().add(BulkUpdateStatus('draft')),
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.delete_forever_rounded,
                  label: 'Del',
                  color: colorScheme.error,
                  onTap: () => _confirmBulkDelete(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected beans?'),
        content: const Text('This action cannot be undone and will remove these beans from your catalog.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false), 
            child: Text('Keep', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ),
          FilledButton(
            onPressed: () => context.pop(true), 
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBeanListBloc>().add(BulkDeleteBeans());
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee_maker_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'Your inventory is empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Import beans using our scraper or\nstart adding them manually.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showScraper(context),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Launch Scraper wizard'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/admin/roastery/${widget.roasteryId}/beans/new');
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add manually'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScraper(BuildContext context) {
    final bloc = context.read<AdminBeanListBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: ScraperBottomSheet(roasteryId: widget.roasteryId),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.error),
          const SizedBox(height: 24),
          Text(
            'Connection Error',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message ?? 'We couldn\'t load your beans right now. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              context.read<AdminBeanListBloc>().add(LoadBeans(widget.roasteryId));
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  void _showFilterSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<AdminBeanListBloc>(),
          child: const _AdminBeanFilterSortSheet(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: activeColor, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: activeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminBeanFilterSortSheet extends StatelessWidget {
  const _AdminBeanFilterSortSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<AdminBeanListBloc>();

    return BlocBuilder<AdminBeanListBloc, AdminBeanListState>(
      buildWhen: (previous, current) {
        return previous.activeFilter != current.activeFilter ||
               previous.sortBy != current.sortBy ||
               previous.sortAscending != current.sortAscending;
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Filter & Sort', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(theme, 'DISPLAY STATUS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFilterChip(context, state, 'All Items', BeanStatusFilter.all.name),
                    _buildFilterChip(context, state, 'Published', BeanStatusFilter.published.name),
                    _buildFilterChip(context, state, 'Drafts', BeanStatusFilter.draft.name),
                    _buildFilterChip(context, state, 'Archived', BeanStatusFilter.unpublished.name),
                  ],
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(theme, 'SORT BY'),
                const SizedBox(height: 12),
                _buildSortRadio(context, state, 'Product Name', AdminBeanSortOption.name),
                _buildSortRadio(context, state, 'Date Created', AdminBeanSortOption.createdAt),
                _buildSortRadio(context, state, 'Last Modified', AdminBeanSortOption.updatedAt),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text('Ordering', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, icon: Icon(Icons.arrow_upward_rounded), label: Text('Asc')),
                        ButtonSegment(value: false, icon: Icon(Icons.arrow_downward_rounded), label: Text('Desc')),
                      ],
                      selected: {state.sortAscending},
                      onSelectionChanged: (Set<bool> selected) {
                        bloc.add(ChangeSortOption(
                          sortOption: state.sortBy,
                          isAscending: selected.first,
                        ));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, AdminBeanListState state, String label, String value) {
    final bool isSelected = state.activeFilter == value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<AdminBeanListBloc>().add(FilterBeans(value));
        }
      },
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSortRadio(BuildContext context, AdminBeanListState state, String label, AdminBeanSortOption option) {
    final isSelected = state.sortBy == option;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RadioListTile<AdminBeanSortOption>(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      value: option,
      groupValue: state.sortBy,
      activeColor: colorScheme.primary,
      onChanged: (AdminBeanSortOption? value) {
        if (value != null) {
          context.read<AdminBeanListBloc>().add(ChangeSortOption(
                sortOption: value,
                isAscending: state.sortAscending,
              ));
        }
      },
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AdminBeanStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _AdminBeanStickyHeaderDelegate({
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.resultCount,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final int resultCount;

  @override
  double get maxExtent => 110;
  @override
  double get minExtent => 110;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPinned = shrinkOffset > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search beans...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: onFilterTap,
                  icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                  tooltip: 'Filters',
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AdminBeanStickyHeaderDelegate oldDelegate) {
    return oldDelegate.resultCount != resultCount ||
        oldDelegate.searchController.text != searchController.text;
  }
}
