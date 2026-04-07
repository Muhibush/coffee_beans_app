import 'package:flutter/material.dart';

class AdminBeanCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String status;
  final VoidCallback? onTap;
  
  // Selection support
  final bool? isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectedChanged;

  const AdminBeanCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.status,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectedChanged,
  });

  Color _getStatusBgColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green.withValues(alpha: 0.1);
      case 'draft':
        return Colors.amber.withValues(alpha: 0.1);
      case 'unpublished':
        return colorScheme.outlineVariant.withValues(alpha: 0.2);
      default:
        return colorScheme.outlineVariant.withValues(alpha: 0.2);
    }
  }

  Color _getStatusTextColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green.shade700;
      case 'draft':
        return Colors.amber.shade900;
      case 'unpublished':
        return colorScheme.outline;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onSelectedChanged != null ? () => onSelectedChanged!(!isSelected) : null,
        borderRadius: BorderRadius.circular(12),
        hoverColor: colorScheme.surfaceContainerLow,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5), width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selection Checkbox
              if (isSelectionMode == true) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: onSelectedChanged,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
              ],

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(colorScheme);
                        },
                      )
                    : _buildPlaceholder(colorScheme),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(colorScheme),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: _getStatusTextColor(colorScheme),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.coffee_rounded, color: colorScheme.onSurfaceVariant),
    );
  }
}
