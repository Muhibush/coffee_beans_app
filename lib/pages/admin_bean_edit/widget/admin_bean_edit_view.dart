import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../model/bean_model.dart';
import '../bloc/admin_bean_edit_bloc.dart';
import '../bloc/admin_bean_edit_event.dart';
import '../bloc/admin_bean_edit_state.dart';
import 'variant_editor_card.dart';
import 'add_chip_bottom_sheet.dart';

class AdminBeanEditView extends StatelessWidget {
  const AdminBeanEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBeanEditBloc, AdminBeanEditState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == AdminBeanEditStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state.status == AdminBeanEditStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Saved successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop();
        } else if (state.status == AdminBeanEditStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bean deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == AdminBeanEditStatus.initial ||
            state.status == AdminBeanEditStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bean = state.bean;
        if (bean == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load data')),
          );
        }

        return _BeanEditForm(bean: bean, isNew: state.isNew, state: state);
      },
    );
  }
}

class _BeanEditForm extends StatefulWidget {
  final Bean bean;
  final bool isNew;
  final AdminBeanEditState state;

  const _BeanEditForm({
    required this.bean,
    required this.isNew,
    required this.state,
  });

  @override
  State<_BeanEditForm> createState() => _BeanEditFormState();
}

class _BeanEditFormState extends State<_BeanEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _altitudeController;

  final List<String> _statusOptions = ['draft', 'published', 'unpublished'];
  final List<String> _roastOptions = [
    'Light', 'Medium-Light', 'Medium', 'Medium-Dark', 'Dark'
  ];
  final List<String> _originOptions = [
    'Java', 'Sumatra', 'Bali', 'Flores', 'Sulawesi', 'Ethiopia', 'Colombia', 'Brazil'
  ];
  final List<String> _processOptions = [
    'Washed', 'Natural', 'Honey', 'Anaerobic Natural', 'Anaerobic Washed'
  ];
  final List<String> _knownVarieties = [
    'Mix Variety', 'Heirloom', 'Typica', 'Bourbon', 'Caturra', 'Geisha'
  ];
  final List<String> _knownNotes = [
    'Berry', 'Strawberry', 'Melon', 'Orange', 'Watermelon', 'Chocolate',
    'Floral', 'Citrus', 'Caramel', 'Nutty', 'Spicy', 'Fruity'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bean.cleanName);
    _altitudeController = TextEditingController(text: widget.bean.altitude ?? '');
  }

  @override
  void didUpdateWidget(covariant _BeanEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bean.cleanName != widget.bean.cleanName &&
        _nameController.text != widget.bean.cleanName) {
      _nameController.text = widget.bean.cleanName;
    }
    if (oldWidget.bean.altitude != widget.bean.altitude &&
        _altitudeController.text != (widget.bean.altitude ?? '')) {
      _altitudeController.text = widget.bean.altitude ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  void _dispatch(AdminBeanEditEvent event) {
    context.read<AdminBeanEditBloc>().add(event);
  }

  void _showSingleSelectBottomSheet(
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) {
    AddChipBottomSheet.show(
      context,
      title: title,
      existingOptions: options,
      onAdd: onSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bean = widget.bean;
    final isSaving = widget.state.status == AdminBeanEditStatus.saving;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          widget.isNew ? 'New Coffee Bean' : 'Edit Coffee Bean',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              const Shadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          if (!widget.isNew)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton.filledTonal(
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                onPressed: isSaving ? null : () => _confirmDelete(),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeroImage(bean),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('IDENTITY'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildTextField('CLEAN PRODUCT NAME', _nameController, (val) {
                        _dispatch(UpdateBeanField('cleanName', val));
                      }),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      _buildDropdownField('STOCK STATUS', _statusOptions, bean.status, (val) {
                        if (val != null) _dispatch(UpdateBeanField('status', val));
                      }),
                    ]),

                    const SizedBox(height: 40),
                    _buildSectionHeader('CHARACTERISTICS'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildBottomSheetSelector(
                        'ORIGIN / REGION',
                        bean.origin ?? 'Select Origin',
                        Icons.public_rounded,
                        () => _showSingleSelectBottomSheet('Select Origin', _originOptions, (val) {
                          _dispatch(UpdateBeanField('origin', val));
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildBottomSheetSelector(
                        'PROCESSING METHOD',
                        bean.process ?? 'Select Process',
                        Icons.settings_input_component_rounded,
                        () => _showSingleSelectBottomSheet('Select Process', _processOptions, (val) {
                          _dispatch(UpdateBeanField('process', val));
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildBottomSheetSelector(
                        'ROAST PROFILE',
                        bean.roastLevel ?? 'Select Roast',
                        Icons.local_fire_department_rounded,
                        () => _showSingleSelectBottomSheet('Select Roast', _roastOptions, (val) {
                          _dispatch(UpdateBeanField('roastLevel', val));
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildTextField('ALTITUDE GUIDELINE', _altitudeController, (val) {
                        _dispatch(UpdateBeanField('altitude', val));
                      }, icon: Icons.terrain_rounded),
                    ]),

                    const SizedBox(height: 40),
                    _buildSectionHeader('GENETICS (VARIETIES)'),
                    const SizedBox(height: 16),
                    _buildChipsSection(
                      items: bean.variety,
                      onAdd: () => _showSingleSelectBottomSheet('Add Variety', _knownVarieties, (val) {
                        if (!bean.variety.contains(val)) {
                          _dispatch(UpdateBeanField('variety', [...bean.variety, val]));
                        }
                      }),
                      onRemove: (val) {
                        _dispatch(UpdateBeanField(
                          'variety',
                          bean.variety.where((v) => v != val).toList(),
                        ));
                      },
                    ),

                    const SizedBox(height: 40),
                    _buildSectionHeader('TASTING NOTES'),
                    const SizedBox(height: 16),
                    _buildChipsSection(
                      items: bean.notes,
                      onAdd: () => _showSingleSelectBottomSheet('Add Tasting Note', _knownNotes, (val) {
                        if (!bean.notes.contains(val)) {
                          _dispatch(UpdateBeanField('notes', [...bean.notes, val]));
                        }
                      }),
                      onRemove: (val) {
                        _dispatch(UpdateBeanField(
                          'notes',
                          bean.notes.where((n) => n != val).toList(),
                        ));
                      },
                    ),

                    const SizedBox(height: 40),
                    Row(
                      children: [
                        _buildSectionHeader('VARIANTS'),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _addNewVariant(bean),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('ADD NEW'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildVariantsSection(bean),
                  ],
                ),
              ),
            ],
          ),

          // Fixed bottom save button with glass effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: FilledButton(
                    onPressed: isSaving ? null : () => _dispatch(SaveBean()),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: colorScheme.primary,
                      elevation: 8,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'PERSIST CHANGES',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
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
        children: children,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged, {
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter value...',
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
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

  Widget _buildDropdownField(
    String label,
    List<String> options,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveValue = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: effectiveValue,
          onChanged: onChanged,
          items: options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt.toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          icon: Icon(Icons.expand_more_rounded, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBottomSheetSelector(String label, String value, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.unfold_more_rounded, size: 20, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSection({
    required List<String> items,
    required VoidCallback onAdd,
    required ValueChanged<String> onRemove,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ...items.map((item) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.secondaryContainer),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSecondaryContainer),
                  onPressed: () => onRemove(item),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'ADD',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addNewVariant(Bean bean) {
    final updated = Map<int, BeanVariant>.from(bean.variants);
    int nextWeight = 250;
    if (bean.variants.isNotEmpty) {
      final weights = bean.variants.keys.toList()..sort();
      nextWeight = weights.last + 250;
    }
    updated[nextWeight] = const BeanVariant(price: 0, buyUrl: '', marketplace: '');
    _dispatch(UpdateBeanField('variants', updated));
  }

  Widget _buildVariantsSection(Bean bean) {
    final entries = bean.variants.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No variants added yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: VariantEditorCard(
            weight: entry.key,
            price: entry.value.price.toString(),
            url: entry.value.buyUrl,
            onDelete: () {
              final updated = Map<int, BeanVariant>.from(bean.variants);
              updated.remove(entry.key);
              _dispatch(UpdateBeanField('variants', updated));
            },
            onWeightChanged: (newWeight) {
              final updated = Map<int, BeanVariant>.from(bean.variants);
              final oldData = updated.remove(entry.key);
              if (oldData != null) {
                updated[newWeight] = oldData;
                _dispatch(UpdateBeanField('variants', updated));
              }
            },
            onPriceChanged: (newPrice) {
              final updated = Map<int, BeanVariant>.from(bean.variants);
              final oldData = updated[entry.key];
              if (oldData != null) {
                final price = int.tryParse(newPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                updated[entry.key] = oldData.copyWith(price: price);
                _dispatch(UpdateBeanField('variants', updated));
              }
            },
            onUrlChanged: (newUrl) {
              final updated = Map<int, BeanVariant>.from(bean.variants);
              final oldData = updated[entry.key];
              if (oldData != null) {
                updated[entry.key] = oldData.copyWith(buyUrl: newUrl);
                _dispatch(UpdateBeanField('variants', updated));
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeroImage(Bean bean) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = bean.imageUrl != null && bean.imageUrl!.isNotEmpty;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(bean.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_not_supported_rounded, size: 64, color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No Image Available', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : null,
          ),
        ),
        // Gradient overlay for readability of AppBar
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'changeImage',
            onPressed: () {
              // Future: Image picker
            },
            elevation: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            icon: Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 20),
            label: Text(
              'CHANGE PHOTO',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bean?'),
        content: const Text('This action cannot be undone. All variants and metadata will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              _dispatch(DeleteBean());
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
