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
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.status == AdminBeanEditStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
          context.pop();
        } else if (state.status == AdminBeanEditStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bean deleted')),
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
    // Update controllers if bean changes from outside (e.g., reload)
    if (oldWidget.bean.cleanName != widget.bean.cleanName) {
      _nameController.text = widget.bean.cleanName;
    }
    if (oldWidget.bean.altitude != widget.bean.altitude) {
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isNew ? 'Add Bean' : 'Edit Bean',
          style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          if (!widget.isNew)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Delete Bean',
              onPressed: isSaving ? null : () => _dispatch(DeleteBean()),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _buildHeroImage(bean),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Info'),
                    const SizedBox(height: 16),
                    _buildTextField('Name', _nameController, (val) {
                      _dispatch(const UpdateBeanField('cleanName', '').copyWithValue(val));
                    }),
                    const SizedBox(height: 16),
                    _buildDropdownField('Status', _statusOptions, bean.status, (val) {
                      if (val != null) _dispatch(UpdateBeanField('status', val));
                    }),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Specs'),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector(
                      'Origin',
                      bean.origin ?? 'Select Origin',
                      () => _showSingleSelectBottomSheet('Select Origin', _originOptions, (val) {
                        _dispatch(UpdateBeanField('origin', val));
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector(
                      'Process',
                      bean.process ?? 'Select Process',
                      () => _showSingleSelectBottomSheet('Select Process', _processOptions, (val) {
                        _dispatch(UpdateBeanField('process', val));
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector(
                      'Roast',
                      bean.roastLevel ?? 'Select Roast',
                      () => _showSingleSelectBottomSheet('Select Roast', _roastOptions, (val) {
                        _dispatch(UpdateBeanField('roastLevel', val));
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Altitude (e.g., 1500 masl)', _altitudeController, (val) {
                      _dispatch(UpdateBeanField('altitude', val));
                    }),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Variety'),
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

                    const SizedBox(height: 32),
                    _buildSectionTitle('Tasting Notes'),
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

                    const SizedBox(height: 32),
                    _buildSectionTitle('Variants'),
                    const SizedBox(height: 16),
                    _buildVariantsSection(bean),
                  ],
                ),
              ),
            ],
          ),

          // Fixed bottom save button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
              child: FilledButton(
                onPressed: isSaving ? null : () => _dispatch(SaveBean()),
                child: isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
    final textTheme = theme.textTheme;

    // Ensure value is in options
    final effectiveValue = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: effectiveValue,
          onChanged: onChanged,
          items: options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt, style: textTheme.bodyLarge),
                  ))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          icon: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBottomSheetSelector(String label, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: textTheme.bodyLarge),
                Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
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
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ...items.map((item) {
          return Chip(
            label: Text(item),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onRemove(item),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
            deleteIconColor: colorScheme.onSecondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            side: BorderSide.none,
          );
        }),
        ActionChip(
          label: const Text('Add'),
          avatar: const Icon(Icons.add, size: 18),
          backgroundColor: Colors.transparent,
          side: BorderSide(
            color: colorScheme.outlineVariant,
            style: BorderStyle.solid,
            width: 2,
          ),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildVariantsSection(Bean bean) {
    final colorScheme = Theme.of(context).colorScheme;
    // Sort entrants numerically by weight (grams)
    final entries = bean.variants.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: [
        ...entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: VariantEditorCard(
              weight: entry.key,
              price: entry.value.price.toString(),
              url: entry.value.buyUrl,
              onDelete: () {
                final updated = Map<int, BeanVariant>.from(bean.variants);
                updated.remove(entry.key);
                _dispatch(UpdateBeanField('variants', updated));
              },
            ),
          );
        }),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          onPressed: () {
            final updated = Map<int, BeanVariant>.from(bean.variants);
            // Default to next 250g increment if possible
            int nextWeight = 250;
            if (entries.isNotEmpty) {
              nextWeight = entries.last.key + 250;
            }
            updated[nextWeight] =
                const BeanVariant(price: 0, buyUrl: '', marketplace: '');
            _dispatch(UpdateBeanField('variants', updated));
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Variant'),
        ),
      ],
    );
  }

  Widget _buildHeroImage(Bean bean) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = bean.imageUrl != null && bean.imageUrl!.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(bean.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Icon(Icons.image_outlined, size: 48, color: colorScheme.outlineVariant)
                : null,
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Image change action — future enhancement
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Change Image',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
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
}

/// Extension to create UpdateBeanField with a runtime value.
extension _UpdateBeanFieldExt on UpdateBeanField {
  UpdateBeanField copyWithValue(String value) {
    return UpdateBeanField(field, value);
  }
}
