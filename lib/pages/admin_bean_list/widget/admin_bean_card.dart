import 'package:flutter/material.dart';

class AdminBeanCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String status;

  const AdminBeanCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.status,
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
        onTap: () {},
        borderRadius: BorderRadius.circular(12), // radiusXl
        hoverColor: colorScheme.surfaceContainerLow,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12), // radiusXl
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // radiusLg
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: colorScheme.surfaceContainerHigh,
                      child: Icon(Icons.image_not_supported, color: colorScheme.onSurfaceVariant),
                    );
                  },
                ),
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
                            borderRadius: BorderRadius.circular(9999), // radiusFull
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
}
