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

  @override
  void dispose() {
    _urlController.dispose();
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
                'Scraped: ${state.scrapedResult?.cleanName ?? "bean"} — saved as draft',
              ),
              backgroundColor: Colors.green.shade700,
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
            Text(
              'Scraper',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _urlController,
                    enabled: !isScraping,
                    decoration: InputDecoration(
                      hintText: 'Paste store/product URL...',
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
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: isScraping
                        ? null
                        : () {
                            final url = _urlController.text.trim();
                            if (url.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a URL')),
                              );
                              return;
                            }
                            context.read<AdminBeanListBloc>().add(
                                  ScrapeUrl(
                                    url: url,
                                    roasteryId: widget.roasteryId,
                                  ),
                                );
                          },
                    child: isScraping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Scrape'),
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
