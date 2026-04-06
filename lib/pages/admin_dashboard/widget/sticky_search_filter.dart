import 'package:flutter/material.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/admin_dashboard_page.dart'; // To get RoasteryFilter

/// A sticky header delegate for the Admin Dashboard providing search and status filtering.
class StickySearchFilter extends SliverPersistentHeaderDelegate {
  StickySearchFilter({
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.resultCount,
  });

  final TextEditingController searchController;
  final RoasteryFilter activeFilter;
  final ValueChanged<RoasteryFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final int resultCount;

  @override
  double get maxExtent => 140;
  @override
  double get minExtent => 140;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    // Show subtle shadow when pinned/overlapping
    final isPinned = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or city',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Filter Chips ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(
                    context,
                    label: 'All',
                    filter: RoasteryFilter.all,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Active',
                    filter: RoasteryFilter.active,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Inactive',
                    filter: RoasteryFilter.inactive,
                  ),
                  const SizedBox(width: 8),
                  // Result count badge
                  Center(
                    child: Text(
                      '$resultCount results',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required RoasteryFilter filter,
  }) {
    final theme = Theme.of(context);
    final isSelected = activeFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickySearchFilter oldDelegate) {
    return oldDelegate.activeFilter != activeFilter ||
        oldDelegate.resultCount != resultCount ||
        oldDelegate.searchController.text != searchController.text;
  }
}
