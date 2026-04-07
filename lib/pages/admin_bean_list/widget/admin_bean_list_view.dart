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
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AdminBeanListBloc, AdminBeanListState>(
      builder: (context, state) {
        final filtered = state.filteredBeans;
        final hasSelection = state.isSelectionMode;

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: const Text('Beans'),
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      if (hasSelection)
                        TextButton(
                          onPressed: () => context.read<AdminBeanListBloc>().add(ClearSelection()),
                          child: const Text('Cancel'),
                        ),
                      if (!hasSelection && filtered.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.select_all),
                          onPressed: () => context.read<AdminBeanListBloc>().add(SelectAllBeans()),
                        ),
                    ],
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
                      padding: EdgeInsets.fromLTRB(16, 16, 16, hasSelection ? 120 : 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final bean = filtered[index];
                          final isUnpublished = bean.status == 'unpublished';
                          final isSelected = state.selectedIds.contains(bean.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildBulkActionBar(context, state),
                ),
            ],
          ),
          floatingActionButton: hasSelection 
              ? null 
              : FloatingActionButton(
                  onPressed: () {
                    context.push('/admin/roastery/${widget.roasteryId}/beans/new');
                  },
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }

  Widget _buildBulkActionBar(BuildContext context, AdminBeanListState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = state.selectedIds.length;

    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'items selected',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            // Actions
            _ActionButton(
              icon: Icons.check_circle_outline,
              label: 'Publish',
              onTap: () => context.read<AdminBeanListBloc>().add(BulkUpdateStatus('published')),
            ),
            _ActionButton(
              icon: Icons.edit_note_rounded,
              label: 'Draft',
              onTap: () => context.read<AdminBeanListBloc>().add(BulkUpdateStatus('draft')),
            ),
            _ActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: colorScheme.error,
              onTap: () => _confirmBulkDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected beans?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.pop(true), 
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: activeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
