import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/design_system/app_colors.dart';
import '../bloc/admin_roastery_edit_bloc.dart';
import '../bloc/admin_roastery_edit_event.dart';
import '../bloc/admin_roastery_edit_state.dart';

class AdminRoasteryEditView extends StatelessWidget {
  const AdminRoasteryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminRoasteryEditBloc, AdminRoasteryEditState>(
      listenWhen: (prev, current) =>
          prev.status != current.status ||
          prev.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == AdminRoasteryEditStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.status == AdminRoasteryEditStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
          context.pop();
        } else if (state.status == AdminRoasteryEditStatus.deleted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Roastery deleted')));
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == AdminRoasteryEditStatus.initial ||
            state.status == AdminRoasteryEditStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roastery = state.roastery;
        if (roastery == null) {
          return const Scaffold(
            body: Center(child: Text("Failed to load data")),
          );
        }

        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Roastery',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Leave space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogoSection(context, state),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileForm(context, state),
                      const SizedBox(height: 32),
                      _buildSocialLinksForm(context, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(context, state),
        );
      },
    );
  }

  Widget _buildLogoSection(BuildContext context, AdminRoasteryEditState state) {
    final roastery = state.roastery!;
    final hasLogo = roastery.logoUrl != null && roastery.logoUrl!.isNotEmpty;

    return GestureDetector(
      onLongPress: () {
        // Simulate uploading a new image for now
        context.read<AdminRoasteryEditBloc>().add(
          const UpdateRoasteryField(
            'logoUrl',
            'https://via.placeholder.com/600x400.png?text=New+Logo',
          ),
        );
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasLogo
                  ? Image.network(roastery.logoUrl!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: AppColors.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Long press to set logo',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, AdminRoasteryEditState state) {
    final roastery = state.roastery!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          context,
          label: 'NAME',
          initialValue: roastery.name,
          hint: 'Enter the roastery brand name',
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('name', val),
          ),
        ),
        const SizedBox(height: 16),
        _buildCityField(context, state),
        const SizedBox(height: 16),
        _buildInputField(
          context,
          label: 'BIO',
          initialValue: roastery.bio ?? '',
          maxLines: 4,
          hint: 'Tell the world your roastery\'s unique story...',
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('bio', val),
          ),
        ),
      ],
    );
  }

  Widget _buildCityField(BuildContext context, AdminRoasteryEditState state) {
    final city = state.roastery!.city;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CITY',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showCityPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              city.isEmpty ? 'Select a city' : city,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: city.isEmpty ? AppColors.outline : AppColors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCityPicker(BuildContext context) {
    final List<String> cities = [
      'Jakarta',
      'Bandung',
      'Surabaya',
      'Medan',
      'Yogyakarta',
      'Bali',
      'Semarang',
      'Makassar',
      'Malang',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select City',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cities.length,
                  itemBuilder: (ctx, i) {
                    final city = cities[i];
                    return ListTile(
                      title: Text(city),
                      onTap: () {
                        context.read<AdminRoasteryEditBloc>().add(
                          UpdateRoasteryField('city', city),
                        );
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialLinksForm(
    BuildContext context,
    AdminRoasteryEditState state,
  ) {
    final links = state.roastery!.socialLinks ?? {};
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Social Presence',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        _buildInputField(
          context,
          label: 'INSTAGRAM',
          initialValue: links['instagram'] ?? '',
          hint: 'instagram.com/yourbrandname',
          prefixIcon: Icons.camera_alt_outlined,
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('instagram', val),
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context,
          label: 'TOKOPEDIA',
          initialValue: links['tokopedia'] ?? '',
          hint: 'tokopedia.com/your-store',
          prefixIcon: Icons.storefront_outlined,
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('tokopedia', val),
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context,
          label: 'SHOPEE',
          initialValue: links['shopee'] ?? '',
          hint: 'shopee.co.id/your-store',
          prefixIcon: Icons.shopping_bag_outlined,
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('shopee', val),
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context,
          label: 'WEBSITE',
          initialValue: links['website'] ?? '',
          hint: 'www.yourwebsite.com',
          prefixIcon: Icons.language_outlined,
          onChanged: (val) => context.read<AdminRoasteryEditBloc>().add(
            UpdateRoasteryField('website', val),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    String? hint,
    IconData? prefixIcon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          maxLines: maxLines,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    AdminRoasteryEditState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          if (!state.isNew) ...[
            Expanded(
              flex: 1,
              child: FilledButton.tonal(
                onPressed:
                    state.status == AdminRoasteryEditStatus.saving ||
                        state.status == AdminRoasteryEditStatus.loading
                    ? null
                    : () => context.read<AdminRoasteryEditBloc>().add(
                        DeleteRoastery(),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed:
                  state.status == AdminRoasteryEditStatus.saving ||
                      state.status == AdminRoasteryEditStatus.loading
                  ? null
                  : () => context.read<AdminRoasteryEditBloc>().add(
                      SaveRoastery(),
                    ),
              child: state.status == AdminRoasteryEditStatus.saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
