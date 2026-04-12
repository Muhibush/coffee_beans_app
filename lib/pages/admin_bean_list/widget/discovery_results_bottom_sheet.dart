import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_bean_list_bloc.dart';
import '../bloc/admin_bean_list_event.dart';
import '../bloc/admin_bean_list_state.dart';

class DiscoveryResultsBottomSheet extends StatefulWidget {
  final String roasteryId;

  const DiscoveryResultsBottomSheet({super.key, required this.roasteryId});

  @override
  State<DiscoveryResultsBottomSheet> createState() =>
      _DiscoveryResultsBottomSheetState();
}

class _DiscoveryResultsBottomSheetState
    extends State<DiscoveryResultsBottomSheet> {
  BulkScrapeScope _scope = BulkScrapeScope.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AdminBeanListBloc, AdminBeanListState>(
      builder: (context, state) {
        final products = state.discoveredProducts;
        final selectedCount = state.selectedDiscoveredUrls.length;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.checklist_rtl_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Discovered Products',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${products.length} Items Found',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<BulkScrapeScope>(
                        value: _scope,
                        isExpanded: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          border: InputBorder.none,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: BulkScrapeScope.all,
                            child: Text('Check All'),
                          ),
                          DropdownMenuItem(
                            value: BulkScrapeScope.newOnly,
                            child: Text('Check New'),
                          ),
                          DropdownMenuItem(
                            value: BulkScrapeScope.updateOnly,
                            child: Text('Check Existing'),
                          ),
                          DropdownMenuItem(
                            value: BulkScrapeScope.none,
                            child: Text('Uncheck All'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _scope = val);
                            context.read<AdminBeanListBloc>().add(
                              ChangeScraperScope(val),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product List
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isSelected = state.selectedDiscoveredUrls.contains(
                        product.url,
                      );

                      return Material(
                        color: isSelected
                            ? colorScheme.primaryContainer.withValues(
                                alpha: 0.2,
                              )
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.read<AdminBeanListBloc>().add(
                            ToggleScraperProductSelection(product),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      context.read<AdminBeanListBloc>().add(
                                        ToggleScraperProductSelection(product),
                                      ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        product.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        context.read<AdminBeanListBloc>().add(
                          CancelScraperWizard(),
                        );
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: selectedCount == 0
                          ? null
                          : () {
                              context.read<AdminBeanListBloc>().add(
                                ConfirmBulkScrape(
                                  roasteryId: widget.roasteryId,
                                  scope: _scope,
                                ),
                              );
                              Navigator.pop(context);
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text('Sync $selectedCount Items'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
