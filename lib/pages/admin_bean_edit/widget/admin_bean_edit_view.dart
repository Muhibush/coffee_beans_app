import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditMode ? 'Edit Bean' : 'Add Bean',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.onSurface),
        ),
        actions: [
          if (widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
                        side: const BorderSide(color: AppColors.outlineVariant),
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
                    AppColors.surface.withOpacity(0.0),
                    AppColors.surface,
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
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: Theme.of(context).textTheme.bodyLarge))).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          icon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBottomSheetSelector(String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
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
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ...items.map((item) {
          return Chip(
            label: Text(item),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onRemove(item),
            backgroundColor: AppColors.secondaryContainer,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSecondaryContainer),
            deleteIconColor: AppColors.onSecondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            side: BorderSide.none,
          );
        }),
        ActionChip(
          label: const Text('Add'),
          avatar: const Icon(Icons.add, size: 18),
          backgroundColor: Colors.transparent,
          side: BorderSide(color: AppColors.outlineVariant, style: BorderStyle.solid, width: 2),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
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
                ? const Icon(Icons.image_outlined, size: 48, color: AppColors.outlineVariant)
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
                        color: AppColors.surfaceCard.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_camera, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Change Image',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
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
