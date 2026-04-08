import 'package:flutter/material.dart';

class VariantEditorCard extends StatefulWidget {
  final int weight;
  final String price;
  final String url;
  final VoidCallback onDelete;
  final ValueChanged<int>? onWeightChanged;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<String>? onUrlChanged;

  const VariantEditorCard({
    super.key,
    required this.weight,
    required this.price,
    required this.url,
    required this.onDelete,
    this.onWeightChanged,
    this.onPriceChanged,
    this.onUrlChanged,
  });

  @override
  State<VariantEditorCard> createState() => _VariantEditorCardState();
}

class _VariantEditorCardState extends State<VariantEditorCard> {
  late TextEditingController _weightController;
  late TextEditingController _priceController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.weight.toString());
    _priceController = TextEditingController(text: widget.price);
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void didUpdateWidget(VariantEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weight != widget.weight &&
        _weightController.text != widget.weight.toString()) {
      _weightController.text = widget.weight.toString();
    }
    if (oldWidget.price != widget.price && _priceController.text != widget.price) {
      _priceController.text = widget.price;
    }
    if (oldWidget.url != widget.url && _urlController.text != widget.url) {
      _urlController.text = widget.url;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: colorScheme.surfaceContainer),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 18, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Variant Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: colorScheme.error),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildField(
                  context,
                  label: 'Weight (grams)',
                  controller: _weightController,
                  icon: Icons.scale_rounded,
                  hint: 'e.g., 250',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final weight = int.tryParse(val) ?? 0;
                    widget.onWeightChanged?.call(weight);
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  context,
                  label: 'Price',
                  controller: _priceController,
                  icon: Icons.payments_outlined,
                  hint: 'e.g., Rp 85.000',
                  onChanged: widget.onPriceChanged,
                ),
                const SizedBox(height: 16),
                _buildField(
                  context,
                  label: 'Product URL',
                  controller: _urlController,
                  icon: Icons.link_rounded,
                  hint: 'Marketplace link...',
                  onChanged: widget.onUrlChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
