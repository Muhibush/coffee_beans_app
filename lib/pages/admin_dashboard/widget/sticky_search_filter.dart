import 'package:flutter/material.dart';

class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}

/// A generic sticky header delegate providing search and status filtering.
class StickySearchFilter<T> extends SliverPersistentHeaderDelegate {
  StickySearchFilter({
    required this.searchController,
    required this.activeFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.resultCount,
    this.searchHint = 'Search...',
  });

  final TextEditingController searchController;
  final T activeFilter;
  final List<FilterOption<T>> filters;
  final ValueChanged<T> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final int resultCount;
  final String searchHint;

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
    final colorScheme = theme.colorScheme;
    // Show subtle shadow when pinned/overlapping
    final isPinned = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
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
                    borderSide: BorderSide(
                      color: colorScheme.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Filter Chips ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...filters.map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(
                          context,
                          label: filter.label,
                          filterValue: filter.value,
                        ),
                      )),
                  // Result count badge
                  Center(
                    child: Text(
                      '$resultCount results',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
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
    required T filterValue,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = activeFilter == filterValue;

    return GestureDetector(
      onTap: () => onFilterChanged(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999), // radiusFull
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickySearchFilter<T> oldDelegate) {
    return oldDelegate.activeFilter != activeFilter ||
        oldDelegate.resultCount != resultCount ||
        oldDelegate.searchController.text != searchController.text;
  }
}
