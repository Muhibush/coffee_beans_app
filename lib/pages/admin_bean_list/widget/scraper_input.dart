import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bean_list_bloc.dart';
import '../bloc/admin_bean_list_event.dart';
import '../bloc/admin_bean_list_state.dart';

/// Scraper input widget — allows pasting a product URL and triggering
/// the Go scraper to extract + save a bean as draft.
class ScraperInput extends StatefulWidget {
  final String roasteryId;

  const ScraperInput({super.key, required this.roasteryId});

  @override
  State<ScraperInput> createState() => _ScraperInputState();
}class _ScraperInputState extends State<ScraperInput> {
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
    // ... rest of build method ...
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet handle/decoration
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Scraper PRO',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: () {
                      context.read<AdminBeanListBloc>().add(CancelScraperWizard());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWizardContent(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWizardContent(BuildContext context, AdminBeanListState state) {
    switch (state.scraperStatus) {
      case ScraperStatus.idle:
        return _buildIdleStep(context);
      case ScraperStatus.inspecting:
        return _buildLoadingStep(context, 'Analyzing URL...');
      case ScraperStatus.selecting:
        return _buildSelectionStep(context, state);
      case ScraperStatus.scraping:
        return _buildProgressStep(context, state);
      case ScraperStatus.success:
        return _buildSuccessStep(context, state);
      case ScraperStatus.error:
        return _buildErrorStep(context, state);
    }
  }

  Widget _buildIdleStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Single Product'),
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
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: _isBulk ? 'Paste Store/Collection URL...' : 'Paste Product URL...',
              label: Text(_isBulk ? 'Bulk URL' : 'Product URL'),
              prefixIcon: const Icon(Icons.link),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_isBulk) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _maxItemsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 20',
                label: const Text('Max Items'),
                prefixIcon: const Icon(Icons.format_list_numbered),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
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
            },
            icon: const Icon(Icons.bolt),
            label: Text(_isBulk ? 'Analyze Store' : 'Scrape Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSelectionStep(BuildContext context, AdminBeanListState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final products = state.discoveredProducts;
    final selectedCount = state.selectedDiscoveredUrls.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: colorScheme.primaryContainer.withOpacity(0.3),
          child: Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Found ${products.length} items',
                  style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () => context.read<AdminBeanListBloc>().add(CancelScraperWizard()),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = state.selectedDiscoveredUrls.contains(product.url);
              return CheckboxListTile(
                value: isSelected,
                title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(product.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall),
                onChanged: (_) {
                  context.read<AdminBeanListBloc>().add(ToggleScraperProductSelection(product));
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<BulkScrapeScope>(
                value: _scope,
                decoration: const InputDecoration(labelText: 'Strategy', isDense: true),
                items: const [
                  DropdownMenuItem(value: BulkScrapeScope.all, child: Text('Overwrite All')),
                  DropdownMenuItem(value: BulkScrapeScope.newOnly, child: Text('Skip Existing (Recommended)')),
                  DropdownMenuItem(value: BulkScrapeScope.updateOnly, child: Text('Update Existing Only')),
                ],
                onChanged: (val) => setState(() => _scope = val!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          context.read<AdminBeanListBloc>().add(
                                ConfirmBulkScrape(roasteryId: widget.roasteryId, scope: _scope),
                              );
                        },
                  child: Text('Scrape $selectedCount Items'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStep(BuildContext context, AdminBeanListState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            state.scraperMessage ?? 'Processing...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep this page open',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context, AdminBeanListState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade600),
          const SizedBox(height: 16),
          Text(
            'Scrape Task Finished',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.scraperMessage ?? 'Items added to your list.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.read<AdminBeanListBloc>().add(CancelScraperWizard()),
              child: const Text('Back to Scraper'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStep(BuildContext context, AdminBeanListState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Scraper Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            state.scraperError ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.read<AdminBeanListBloc>().add(CancelScraperWizard()),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final url = _urlController.text.trim();
                    if (url.isEmpty) {
                      context.read<AdminBeanListBloc>().add(CancelScraperWizard());
                    } else {
                      context.read<AdminBeanListBloc>().add(
                            StartScraperWizard(url: url, roasteryId: widget.roasteryId),
                          );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
