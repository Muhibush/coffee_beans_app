import 'package:flutter/material.dart';
import 'package:coffee_beans_app/widget/status_badge.dart';

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

  // Badge for session actions
  final String? sessionBadge;

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
    this.sessionBadge,
  });

  StatusBadge _buildStatusBadge(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'published':
        return StatusBadge(
          label: 'PUBLISHED',
          backgroundColor: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimary,
        );
      case 'draft':
        return StatusBadge(
          label: 'DRAFT',
          backgroundColor: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
        );
      case 'unpublished':
      default:
        return StatusBadge(
          label: status.toUpperCase(),
          backgroundColor: colorScheme.surfaceContainerHighest,
          textColor: colorScheme.onSurfaceVariant,
        );
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
        onLongPress: onSelectedChanged != null
            ? () => onSelectedChanged!(!isSelected)
            : null,
        borderRadius: BorderRadius.circular(12),
        hoverColor: colorScheme.surfaceContainerLow,
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'bean_image_$title',
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
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    _buildStatusBadge(colorScheme),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),

                        if (sessionBadge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sessionBadge!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
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
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.coffee_rounded,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
