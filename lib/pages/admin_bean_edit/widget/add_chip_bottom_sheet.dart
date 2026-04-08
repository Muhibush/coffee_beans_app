import 'package:flutter/material.dart';

class AddChipBottomSheet extends StatefulWidget {
  final String title;
  final List<String> existingOptions;
  final ValueChanged<String> onAdd;

  const AddChipBottomSheet({
    super.key,
    required this.title,
    required this.existingOptions,
    required this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<String> existingOptions,
    required ValueChanged<String> onAdd,
  }) {
    final theme = Theme.of(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      barrierColor: theme.colorScheme.scrim.withValues(alpha: 0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      builder: (context) => AddChipBottomSheet(
        title: title,
        existingOptions: existingOptions,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<AddChipBottomSheet> createState() => _AddChipBottomSheetState();
}

class _AddChipBottomSheetState extends State<AddChipBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.existingOptions;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.existingOptions;
      } else {
        _filteredOptions = widget.existingOptions
            .where((opt) => opt.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _submit(String value) {
    if (value.trim().isNotEmpty) {
      widget.onAdd(value.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              onChanged: _filterOptions,
              onSubmitted: _submit,
              autofocus: true,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Type to filter or add new...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded, color: colorScheme.onPrimary, size: 20),
                        ),
                        onPressed: () => _submit(_controller.text),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SUGGESTED OPTIONS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredOptions.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _submit(option),
                            borderRadius: BorderRadius.circular(12),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.surfaceContainer),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    option,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 40, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No matching options found.\nHit enter or tap the + button to add.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
