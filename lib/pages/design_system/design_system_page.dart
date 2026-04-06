import 'package:flutter/material.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';
import 'package:coffee_beans_app/widget/stat_chip.dart';
import 'package:coffee_beans_app/widget/status_badge.dart';

/// A living design system documentation page.
/// 
/// Displays typography, colors, and reusable components defined in the 
/// app's design system.
class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _Section(
            title: 'Typography',
            subtitle: 'Inter (Google Fonts) with material scale',
            child: const _TypographySection(),
          ),
          const SizedBox(height: 48),
          _Section(
            title: 'Colors',
            subtitle: 'Brand palette & surface tokens',
            child: const _ColorSection(),
          ),
          const SizedBox(height: 48),
          _Section(
            title: 'Reusable Components',
            subtitle: 'Global atomic & composite widgets',
            child: const _ComponentSection(),
          ),
          const SizedBox(height: 48),
          _Section(
            title: 'Buttons',
            subtitle: 'Themed Material 3 actions',
            child: const _ButtonSection(),
          ),
          const SizedBox(height: 48),
          _Section(
            title: 'Form Fields',
            subtitle: 'Input system with hint and validation styles',
            child: const _InputSection(),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeRow(label: 'Headline Large', style: theme.textTheme.headlineLarge!),
        _TypeRow(label: 'Headline Medium', style: theme.textTheme.headlineMedium!),
        _TypeRow(label: 'Headline Small', style: theme.textTheme.headlineSmall!),
        const Divider(height: 32),
        _TypeRow(label: 'Title Large', style: theme.textTheme.titleLarge!),
        _TypeRow(label: 'Title Medium', style: theme.textTheme.titleMedium!),
        _TypeRow(label: 'Title Small', style: theme.textTheme.titleSmall!),
        const Divider(height: 32),
        _TypeRow(label: 'Body Large', style: theme.textTheme.bodyLarge!),
        _TypeRow(label: 'Body Medium', style: theme.textTheme.bodyMedium!),
        _TypeRow(label: 'Body Small', style: theme.textTheme.bodySmall!),
        const Divider(height: 32),
        _TypeRow(label: 'Label Large', style: theme.textTheme.labelLarge!),
        _TypeRow(label: 'Label Medium', style: theme.textTheme.labelMedium!),
        _TypeRow(label: 'Label Small', style: theme.textTheme.labelSmall!),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final String label;
  final TextStyle style;

  const _TypeRow({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(label, style: style),
        ],
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _ColorSwatch(name: 'Primary', color: AppColors.primary),
        _ColorSwatch(name: 'Secndry', color: AppColors.secondary),
        _ColorSwatch(name: 'Tertiry', color: AppColors.tertiary),
        _ColorSwatch(name: 'Surface', color: AppColors.surfaceBackground),
        _ColorSwatch(name: 'Card', color: AppColors.surfaceCard),
        _ColorSwatch(name: 'Outline', color: AppColors.outline),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String name;
  final Color color;

  const _ColorSwatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _ComponentSection extends StatelessWidget {
  const _ComponentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Badge', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: const [
            StatusBadge(isActive: true),
            SizedBox(width: 8),
            StatusBadge(isActive: false),
          ],
        ),
        const SizedBox(height: 24),
        Text('Stat Chip', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: const [
            StatChip(
              icon: Icons.store_rounded,
              value: '12',
              label: 'Roasteries',
              color: AppColors.primaryContainer,
            ),
            SizedBox(width: 8),
            StatChip(
              icon: Icons.inventory_2_rounded,
              value: '150',
              label: 'Beans',
              color: AppColors.secondaryContainer,
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonSection extends StatelessWidget {
  const _ButtonSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Primary Action'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.inventory_2_outlined, size: 20),
                label: const Text('Secondary'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                ),
                child: const Text('Danger'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: () {},
            child: const Text('Tonal Button'),
          ),
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            label: Text('INPUT LABEL'),
            hintText: 'Enter some information here...',
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: 'Selected Value',
          decoration: const InputDecoration(
            label: Text('WITH PREFIX ICON'),
            prefixIcon: Icon(Icons.language_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            label: Text('MULTI-LINE TEXT AREA'),
            hintText: 'Tell a story with multiple lines...',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'DYNAMC FIELD TITLE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Custom title pattern used in rosters...',
          ),
        ),
      ],
    );
  }
}
