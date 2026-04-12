import 'package:coffee_beans_app/pages/admin_bean_list/bloc/admin_bean_list_bloc.dart';
import 'package:coffee_beans_app/pages/admin_bean_list/bloc/admin_bean_list_event.dart';
import 'package:coffee_beans_app/pages/admin_bean_list/bloc/admin_bean_list_state.dart';
import 'package:coffee_beans_app/pages/admin_bean_list/widget/admin_bean_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminBeanFilterSortSheet extends StatelessWidget {
  const AdminBeanFilterSortSheet({super.key});

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
                // Drag handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Filter & Sort', style: theme.textTheme.titleLarge),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(theme, 'DISPLAY STATUS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFilterChip(
                      context,
                      state,
                      'All Items',
                      BeanStatusFilter.all.name,
                    ),
                    _buildFilterChip(
                      context,
                      state,
                      'Published',
                      BeanStatusFilter.published.name,
                    ),
                    _buildFilterChip(
                      context,
                      state,
                      'Drafts',
                      BeanStatusFilter.draft.name,
                    ),
                    _buildFilterChip(
                      context,
                      state,
                      'Archived',
                      BeanStatusFilter.unpublished.name,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(theme, 'SORT BY'),
                const SizedBox(height: 12),
                _buildSortRadio(
                  context,
                  state,
                  'Product Name',
                  AdminBeanSortOption.name,
                ),
                _buildSortRadio(
                  context,
                  state,
                  'Date Created',
                  AdminBeanSortOption.createdAt,
                ),
                _buildSortRadio(
                  context,
                  state,
                  'Last Modified',
                  AdminBeanSortOption.updatedAt,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      'Ordering',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.arrow_upward_rounded),
                          label: Text('Asc'),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.arrow_downward_rounded),
                          label: Text('Desc'),
                        ),
                      ],
                      selected: {state.sortAscending},
                      onSelectionChanged: (Set<bool> selected) {
                        bloc.add(
                          ChangeSortOption(
                            sortOption: state.sortBy,
                            isAscending: selected.first,
                          ),
                        );
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

  Widget _buildFilterChip(
    BuildContext context,
    AdminBeanListState state,
    String label,
    String value,
  ) {
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

  Widget _buildSortRadio(
    BuildContext context,
    AdminBeanListState state,
    String label,
    AdminBeanSortOption option,
  ) {
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
          context.read<AdminBeanListBloc>().add(
            ChangeSortOption(
              sortOption: value,
              isAscending: state.sortAscending,
            ),
          );
        }
      },
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
