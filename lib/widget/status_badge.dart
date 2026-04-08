import 'package:flutter/material.dart';

/// A chip-like badge that displays a status with custom label and colors.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory for roastery activity status
  factory StatusBadge.roastery({required bool isActive, required ColorScheme colorScheme}) {
    return StatusBadge(
      label: isActive ? 'ACTIVE' : 'INACTIVE',
      backgroundColor: isActive
          ? colorScheme.tertiaryContainer
          : colorScheme.surfaceContainerHighest,
      textColor: isActive
          ? colorScheme.onTertiaryContainer
          : colorScheme.onSurfaceVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999), // radiusFull
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: textColor,
        ),
      ),
    );
  }
}
