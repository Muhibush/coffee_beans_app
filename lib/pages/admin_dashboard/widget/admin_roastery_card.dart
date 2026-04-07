import 'package:flutter/material.dart';
import 'package:coffee_beans_app/model/roastery.dart';
import 'package:coffee_beans_app/widget/status_badge.dart';

/// The card used in the Admin Dashboard to display a roastery overview.
class AdminRoasteryCard extends StatelessWidget {
  final Roastery roastery;
  final int index;
  final VoidCallback onTap;

  const AdminRoasteryCard({
    super.key,
    required this.roastery,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInactive = !roastery.isActive;

    // Generate distinct avatar colors based on index using colorScheme slots
    final avatarColors = [
      colorScheme.primaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.secondary,
      colorScheme.primary,
      colorScheme.tertiary,
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12), // radiusXl
            child: Ink(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12), // radiusXl
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ── Avatar / Logo ──
                    _buildRoasteryAvatar(context, roastery, avatarColor, isInactive),
                    const SizedBox(width: 16),
                    // ── Info ──
                    Expanded(
                      child: Opacity(
                        opacity: isInactive ? 0.5 : 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roastery.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  roastery.city,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${roastery.beanCount} coffee beans',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                // ── Status Badge ──
                                StatusBadge(isActive: roastery.isActive),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoasteryAvatar(BuildContext context, Roastery roastery, Color color, bool isInactive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isInactive ? colorScheme.surfaceContainer : color,
        borderRadius: BorderRadius.circular(12), // radiusXl
      ),
      child: Center(
        child: Text(
          roastery.name.isNotEmpty
              ? roastery.name.substring(0, 1).toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isInactive
                ? colorScheme.onSurfaceVariant
                : colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}
