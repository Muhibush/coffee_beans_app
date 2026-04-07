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
}

class _ScraperInputState extends State<ScraperInput> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _maxProductsController = TextEditingController();

  bool _isBulk = false;
  BulkScrapeScope _scope = BulkScrapeScope.all;

  @override
  void dispose() {
    _urlController.dispose();
    _maxProductsController.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.scraperMessage ??
                    'Scraped: ${state.scrapedResult?.cleanName ?? "bean"} — saved as draft',
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state.scraperStatus == ScraperStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.scraperError ?? 'Scraping failed'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isScraping = state.scraperStatus == ScraperStatus.scraping;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scraper',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle Switch for Bulk
                Row(
                  children: [
                    Text('Bulk', style: theme.textTheme.bodySmall),
                    Switch(
                      value: _isBulk,
                      onChanged: isScraping
                          ? null
                          : (val) => setState(() => _isBulk = val),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Reporting UI
                  if (isScraping) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.scraperMessage ?? 'Initializing...',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, 
                                size: 14, color: colorScheme.error),
                              const SizedBox(width: 4),
                              Text(
                                'IMPORTANT: Do not close or leave this page.',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _urlController,
                    enabled: !isScraping,
                    decoration: InputDecoration(
                      hintText: _isBulk
                          ? 'Paste shop/collection URL...'
                          : 'Paste product URL...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  if (_isBulk) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Max Products
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _maxProductsController,
                            keyboardType: TextInputType.number,
                            enabled: !isScraping,
                            decoration: InputDecoration(
                              labelText: 'Max Items',
                              hintText: '0 = All',
                              isDense: true,
                              filled: true,
                              fillColor: colorScheme.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Scope
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<BulkScrapeScope>(
                            initialValue: _scope,
                            isDense: true,
                            decoration: InputDecoration(
                              labelText: 'Scope',
                              filled: true,
                              fillColor: colorScheme.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: BulkScrapeScope.all,
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: BulkScrapeScope.newOnly,
                                child: Text('New Only'),
                              ),
                              DropdownMenuItem(
                                value: BulkScrapeScope.updateOnly,
                                child: Text('Update'),
                              ),
                            ],
                            onChanged: isScraping
                                ? null
                                : (val) {
                                    if (val != null) setState(() => _scope = val);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isScraping
                        ? null
                        : () {
                            final url = _urlController.text.trim();
                            if (url.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter a URL')),
                              );
                              return;
                            }

                            if (_isBulk) {
                              final maxStr = _maxProductsController.text.trim();
                              final max = maxStr.isEmpty ? 0 : (int.tryParse(maxStr) ?? 0);
                              context.read<AdminBeanListBloc>().add(
                                    ScrapeBulkUrl(
                                      url: url,
                                      roasteryId: widget.roasteryId,
                                      maxProducts: max,
                                      scope: _scope,
                                    ),
                                  );
                            } else {
                              context.read<AdminBeanListBloc>().add(
                                    ScrapeUrl(
                                      url: url,
                                      roasteryId: widget.roasteryId,
                                    ),
                                  );
                            }
                          },
                    child: isScraping
                        ? const Text('Scraping...')
                        : Text(_isBulk ? 'Bulk Scrape' : 'Scrape'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
