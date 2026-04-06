import 'package:flutter/material.dart';
import 'package:coffee_beans_app/theme/app_theme.dart';

/// Design System showcase page recreating the Stitch "Kopi Essentials"
/// design system guide. Displays color palette, typography scale, and
/// footer with documentation links.
class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background blur decorations ──
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -96,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -96,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // ── Main content ──
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorPalette(context),
                    const SizedBox(height: 80),
                    _buildTypographyScale(context),
                    const SizedBox(height: 128),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Color Palette Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildColorPalette(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with divider
        _buildSectionHeader(context, 'Color Palette'),
        const SizedBox(height: 32),
        // Color swatches grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
              children: [
                _buildColorSwatch(
                  theme,
                  color: AppColors.primaryContainer,
                  name: 'Primary',
                  hex: '#6F4E37',
                ),
                _buildColorSwatch(
                  theme,
                  color: AppColors.primaryDark,
                  name: 'Primary Dark',
                  hex: '#4A3428',
                ),
                _buildColorSwatch(
                  theme,
                  color: AppColors.surfaceBackground,
                  name: 'Surface Background',
                  hex: '#FBF8F4',
                  showOutline: true,
                ),
                _buildColorSwatch(
                  theme,
                  color: AppColors.surfaceCard,
                  name: 'Surface Card',
                  hex: '#FFFFFF',
                  showOutline: true,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSwatch(
    ThemeData theme, {
    required Color color,
    required String name,
    required String hex,
    bool showOutline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: showOutline
                  ? Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hex,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Typography Scale Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTypographyScale(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Typography Scale'),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Headline Large
              _buildTypographyRow(
                theme,
                spec: 'Headline Large / 24px / Bold',
                sample: 'The Art of the Single Origin',
                sampleStyle: theme.textTheme.headlineLarge!,
                usage: 'Editorial Headlines',
              ),
              _buildTypographyDivider(),
              // Title Medium
              _buildTypographyRow(
                theme,
                spec: 'Title Medium / 16px / Semibold',
                sample: 'Toraja Sapan Village Roast',
                sampleStyle: theme.textTheme.titleMedium!,
                usage: 'Product Labels',
              ),
              _buildTypographyDivider(),
              // Body Medium
              _buildTypographyRow(
                theme,
                spec: 'Body Medium / 14px / Regular',
                sample:
                    'Our dark roast brings out the natural oils of the coffee '
                    'bean, creating a heavy-bodied cup with notes of cocoa '
                    'and pipe tobacco.',
                sampleStyle: theme.textTheme.bodyMedium!,
                usage: 'Narrative Text',
                isLongSample: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypographyRow(
    ThemeData theme, {
    required String spec,
    required String sample,
    required TextStyle sampleStyle,
    required String usage,
    bool isLongSample = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          final specLabel = Text(
            spec.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
              color: AppColors.outline,
            ),
          );
          final sampleText = isLongSample
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(sample, style: sampleStyle),
                )
              : Text(sample, style: sampleStyle);
          final usageLabel = Text(
            usage,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.onSurfaceVariant,
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      specLabel,
                      const SizedBox(height: 4),
                      sampleText,
                    ],
                  ),
                ),
                usageLabel,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              specLabel,
              const SizedBox(height: 4),
              sampleText,
              const SizedBox(height: 8),
              usageLabel,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypographyDivider() {
    return Divider(
      color: AppColors.outlineVariant.withValues(alpha: 0.1),
      thickness: 1,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Footer Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Divider(color: AppColors.surfaceVariant, thickness: 1),
        const SizedBox(height: 64),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;

            final branding = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kopi Essentials',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'System documentation v1.0.4. Built for enthusiasts, '
                    'roasters, and curators of the Indonesian archipelago.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );

            final links = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFooterLinkGroup(
                  theme,
                  title: 'The System',
                  items: [
                    'Atelier Principles',
                    'Asset Library',
                    'Component Specs',
                  ],
                ),
                const SizedBox(width: 48),
                _buildFooterLinkGroup(
                  theme,
                  title: 'Origins',
                  items: ['Java', 'Sumatra', 'Sulawesi'],
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [branding, links],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [branding, const SizedBox(height: 32), links],
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFooterLinkGroup(
    ThemeData theme, {
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Shared Helpers
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 1, color: AppColors.surfaceVariant)),
      ],
    );
  }
}
