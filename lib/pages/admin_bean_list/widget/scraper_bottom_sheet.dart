import 'package:coffee_beans_app/pages/admin_bean_list/widget/discovery_results_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_bean_list_bloc.dart';
import '../bloc/admin_bean_list_event.dart';
import '../bloc/admin_bean_list_state.dart';

class ScraperBottomSheet extends StatefulWidget {
  final String roasteryId;

  const ScraperBottomSheet({super.key, required this.roasteryId});

  @override
  State<ScraperBottomSheet> createState() => _ScraperBottomSheetState();
}

class _ScraperBottomSheetState extends State<ScraperBottomSheet> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _maxItemsController = TextEditingController();
  BulkScrapeScope _scope = BulkScrapeScope.all;
  bool _isBulk = false;

  @override
  void dispose() {
    _urlController.dispose();
    _maxItemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<AdminBeanListBloc, AdminBeanListState>(
      listenWhen: (prev, curr) => prev.scraperStatus != curr.scraperStatus,
      listener: (context, state) {
        if (state.scraperStatus == ScraperStatus.success) {
          _urlController.clear();
        }
      },
      builder: (context, state) {
        if (state.scraperStatus == ScraperStatus.selecting) {
          return DiscoveryResultsBottomSheet(roasteryId: widget.roasteryId);
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Allow sheet to wrap content if small
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
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
                      Icons.bolt_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Scraper Wizard', style: theme.textTheme.titleLarge),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 32),
              Flexible(child: _buildWizardContent(context, theme, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWizardContent(
    BuildContext context,
    ThemeData theme,
    AdminBeanListState state,
  ) {
    switch (state.scraperStatus) {
      case ScraperStatus.idle:
      case ScraperStatus.inspecting:
        return _buildIdleStep(context, theme, state);
      default:
        return _buildIdleStep(context, theme, state);
    }
  }

  Widget _buildIdleStep(
    BuildContext context,
    ThemeData theme,
    AdminBeanListState state,
  ) {
    final colorScheme = theme.colorScheme;
    final isInspecting = state.scraperStatus == ScraperStatus.inspecting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Single Item'),
                    // icon: Icon(Icons.description_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Bulk Store'),
                    // icon: Icon(Icons.grid_view_outlined),
                  ),
                ],
                selected: {_isBulk},
                onSelectionChanged: (newSelection) {
                  setState(() => _isBulk = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align fields at the top
                children: [
                  // URL Field
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TARGET URL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText: _isBulk
                                ? 'https://tokopedia.com/roastery-name'
                                : 'https://tokopedia.com/product-url',
                            border:
                                const OutlineInputBorder(), // Added for better visual structure
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conditional Max Items Field
                  if (_isBulk) ...[
                    const SizedBox(width: 12), // Gap between fields
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCRAPE LIMIT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextField(
                            controller: _maxItemsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 25',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton(
            onPressed: isInspecting
                ? null
                : () {
                    final url = _urlController.text.trim();
                    if (url.isEmpty) return;

                    final maxProducts =
                        int.tryParse(_maxItemsController.text) ?? 0;

                    context.read<AdminBeanListBloc>().add(
                      StartScraperWizard(
                        url: url,
                        roasteryId: widget.roasteryId,
                        isBulk: _isBulk,
                        maxProducts: _isBulk ? maxProducts : null,
                      ),
                    );
                    if (!_isBulk) {
                      Navigator.pop(context);
                    }
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isInspecting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    _isBulk ? 'Explore Products' : 'Extract Bean Data',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
