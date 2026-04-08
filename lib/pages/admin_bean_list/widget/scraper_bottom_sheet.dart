import 'package:flutter/material.dart';
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
  final TextEditingController _maxItemsController = TextEditingController(text: '10');
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
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Allow sheet to wrap content if small
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
                      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.bolt_rounded, size: 20, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scraper Wizard',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: () {
                      context.read<AdminBeanListBloc>().add(CancelScraperWizard());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Content
              Flexible(
                child: _buildWizardContent(context, theme, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWizardContent(BuildContext context, ThemeData theme, AdminBeanListState state) {
    switch (state.scraperStatus) {
      case ScraperStatus.idle:
        return _buildIdleStep(context, theme);
      case ScraperStatus.inspecting:
        return _buildLoadingStep(context, theme, 'Analyzing marketplace source...');
      case ScraperStatus.selecting:
        return _buildSelectionStep(context, theme, state);
      default:
        return _buildIdleStep(context, theme);
    }
  }

  Widget _buildIdleStep(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Single Item'),
                    icon: Icon(Icons.description_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Bulk Store'),
                    icon: Icon(Icons.grid_view_outlined),
                  ),
                ],
                selected: {_isBulk},
                onSelectionChanged: (newSelection) {
                  setState(() => _isBulk = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'TARGET URL',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: _isBulk ? 'https://tokopedia.com/roastery-name' : 'https://tokopedia.com/product-url',
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              if (_isBulk) ...[
                const SizedBox(height: 24),
                Text(
                  'SCRAPE LIMIT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _maxItemsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 25',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isEmpty) return;
            
            final maxProducts = int.tryParse(_maxItemsController.text) ?? 10;
            
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
          icon: const Icon(Icons.auto_awesome_rounded),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          label: Text(_isBulk ? 'Explore Products' : 'Extract Bean Data'),
        ),
      ],
    );
  }

  Widget _buildLoadingStep(BuildContext context, ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message, 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionStep(BuildContext context, ThemeData theme, AdminBeanListState state) {
    final colorScheme = theme.colorScheme;
    final products = state.discoveredProducts;
    final selectedCount = state.selectedDiscoveredUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${products.length} Items Found',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<BulkScrapeScope>(
                  value: _scope,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true, 
                    contentPadding: EdgeInsets.zero, 
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  items: const [
                    DropdownMenuItem(value: BulkScrapeScope.all, child: Text('Check All')),
                    DropdownMenuItem(value: BulkScrapeScope.newOnly, child: Text('Check New')),
                    DropdownMenuItem(value: BulkScrapeScope.updateOnly, child: Text('Check Existing')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _scope = val);
                      context.read<AdminBeanListBloc>().add(ChangeScraperScope(val));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = state.selectedDiscoveredUrls.contains(product.url);
              
              return Material(
                color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.read<AdminBeanListBloc>().add(ToggleScraperProductSelection(product)),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => context.read<AdminBeanListBloc>().add(ToggleScraperProductSelection(product)),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title, 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                product.url, 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: selectedCount == 0
              ? null
              : () {
                  context.read<AdminBeanListBloc>().add(
                        ConfirmBulkScrape(roasteryId: widget.roasteryId, scope: _scope),
                      );
                  Navigator.pop(context);
                },
          icon: const Icon(Icons.cloud_download_rounded),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          label: Text('Sync $selectedCount Items'),
        ),
      ],
    );
  }
}
