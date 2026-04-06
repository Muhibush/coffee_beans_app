import 'package:flutter/material.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';

/// A chip-like badge that displays the Roastery's status (Active/Inactive).
class StatusBadge extends StatelessWidget {
  final bool isActive;

  const StatusBadge({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.tertiaryContainer
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isActive
              ? AppColors.onTertiaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
