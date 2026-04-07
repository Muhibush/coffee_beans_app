import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'variant_editor_card.dart';
import 'add_chip_bottom_sheet.dart';

// A simple local model for variants to use in state
class VariantUiModel {
  String weight;
  String price;
  String url;
  VariantUiModel({required this.weight, required this.price, required this.url});
}

class AdminBeanEditView extends StatefulWidget {
  final bool isEditMode;
  // Initialize with some dummy data if edit mode, otherwise empty
  final String? initialName;
  final String? initialStatus;
  final String? initialOrigin;
  final String? initialProcess;
  final String? initialRoast;
  final String? initialAltitude;
  final List<String> initialVarieties;
  final List<String> initialNotes;
  final List<VariantUiModel> initialVariants;
  final String? initialImageUrl;

  const AdminBeanEditView({
    super.key,
    this.isEditMode = true,
    this.initialName,
    this.initialStatus,
    this.initialOrigin,
    this.initialProcess,
    this.initialRoast,
    this.initialAltitude,
    this.initialVarieties = const [],
    this.initialNotes = const [],
    this.initialVariants = const [],
    this.initialImageUrl,
  });

  @override
  State<AdminBeanEditView> createState() => _AdminBeanEditViewState();
}

class _AdminBeanEditViewState extends State<AdminBeanEditView> {
  late TextEditingController _nameController;
  late TextEditingController _altitudeController;
  
  String _status = 'Draft';
  String? _origin;
  String? _process;
  String? _roast;
  
  List<String> _varieties = [];
  List<String> _notes = [];
  List<VariantUiModel> _variants = [];

  final List<String> _statusOptions = ['Draft', 'Published', 'Archived'];
  final List<String> _roastOptions = ['Light', 'Medium-Light', 'Medium', 'Medium-Dark', 'Dark'];
  final List<String> _originOptions = ['Java', 'Sumatra', 'Bali', 'Flores', 'Sulawesi', 'Ethiopia', 'Colombia', 'Brazil'];
  final List<String> _processOptions = ['Washed', 'Natural', 'Honey', 'Anaerobic Natural', 'Anaerobic Washed'];
  
  final List<String> _knownVarieties = ['Mix Variety', 'Heirloom', 'Typica', 'Bourbon', 'Caturra', 'Geisha'];
  final List<String> _knownNotes = ['Berry', 'Strawberry', 'Melon', 'Orange', 'Watermelon', 'Chocolate', 'Floral'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _altitudeController = TextEditingController(text: widget.initialAltitude ?? '');
    if (widget.initialStatus != null && _statusOptions.contains(widget.initialStatus)) {
      _status = widget.initialStatus!;
    }
    _origin = widget.initialOrigin;
    _process = widget.initialProcess;
    _roast = widget.initialRoast;
    _varieties = List.from(widget.initialVarieties);
    _notes = List.from(widget.initialNotes);
    _variants = widget.initialVariants.isNotEmpty 
      ? widget.initialVariants 
      : (widget.isEditMode ? [] : [VariantUiModel(weight: '', price: '', url: '')]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  void _showSingleSelectBottomSheet(String title, List<String> options, ValueChanged<String> onSelected) {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditMode ? 'Edit Bean' : 'Add Bean',
          style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          if (widget.isEditMode)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Delete Bean',
              onPressed: () {
                // Delete action
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _buildHeroImage(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Info'),
                    const SizedBox(height: 16),
                    _buildTextField('Name', _nameController),
                    const SizedBox(height: 16),
                    _buildDropdownField('Status', _statusOptions, _status, (val) {
                      if (val != null) setState(() => _status = val);
                    }),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Specs'),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector('Origin', _origin ?? 'Select Origin', () {
                      _showSingleSelectBottomSheet('Select Origin', _originOptions, (val) {
                        setState(() => _origin = val);
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector('Process', _process ?? 'Select Process', () {
                      _showSingleSelectBottomSheet('Select Process', _processOptions, (val) {
                        setState(() => _process = val);
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildBottomSheetSelector('Roast', _roast ?? 'Select Roast', () {
                      _showSingleSelectBottomSheet('Select Roast', _roastOptions, (val) {
                        setState(() => _roast = val);
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildTextField('Altitude (e.g., 1500 masl)', _altitudeController),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Variety'),
                    const SizedBox(height: 16),
                    _buildChipsSection(
                      items: _varieties,
                      onAdd: () {
                        _showSingleSelectBottomSheet('Add Variety', _knownVarieties, (val) {
                          if (!_varieties.contains(val)) setState(() => _varieties.add(val));
                        });
                      },
                      onRemove: (val) {
                        setState(() => _varieties.remove(val));
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Tasting Notes'),
                    const SizedBox(height: 16),
                    _buildChipsSection(
                      items: _notes,
                      onAdd: () {
                        _showSingleSelectBottomSheet('Add Tasting Note', _knownNotes, (val) {
                          if (!_notes.contains(val)) setState(() => _notes.add(val));
                        });
                      },
                      onRemove: (val) {
                        setState(() => _notes.remove(val));
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Variants'),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _variants.length,
                      itemBuilder: (context, index) {
                        final variant = _variants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: VariantEditorCard(
                            weight: variant.weight,
                            price: variant.price,
                            url: variant.url,
                            onDelete: () {
                              setState(() => _variants.removeAt(index));
                            },
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      onPressed: () {
                        setState(() => _variants.add(VariantUiModel(weight: '', price: '', url: '')));
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Variant'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Fixed bottom button
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
                onPressed: () {
                  // Save action
                  context.pop();
                },
                child: const Text('Save'),
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

  Widget _buildTextField(String label, TextEditingController controller) {
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

  Widget _buildDropdownField(String label, List<String> options, String value, ValueChanged<String?> onChanged) {
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: textTheme.bodyLarge))).toList(),
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
                Text(
                  value,
                  style: textTheme.bodyLarge,
                ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSecondaryContainer),
            deleteIconColor: colorScheme.onSecondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            side: BorderSide.none,
          );
        }),
        ActionChip(
          label: const Text('Add'),
          avatar: const Icon(Icons.add, size: 18),
          backgroundColor: Colors.transparent,
          side: BorderSide(color: colorScheme.outlineVariant, style: BorderStyle.solid, width: 2),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
              image: widget.initialImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(widget.initialImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: widget.initialImageUrl == null
                ? Icon(Icons.image_outlined, size: 48, color: colorScheme.outlineVariant)
                : null,
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Change image action
                },
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
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
                            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                          ),
                        ],
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
}
