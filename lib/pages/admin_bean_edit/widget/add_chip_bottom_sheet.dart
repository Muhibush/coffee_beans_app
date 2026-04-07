import 'package:flutter/material.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';

class AddChipBottomSheet extends StatefulWidget {
  final String title;
  final List<String> existingOptions;
  final ValueChanged<String> onAdd;

  const AddChipBottomSheet({
    super.key,
    required this.title,
    required this.existingOptions,
    required this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<String> existingOptions,
    required ValueChanged<String> onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => AddChipBottomSheet(
        title: title,
        existingOptions: existingOptions,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<AddChipBottomSheet> createState() => _AddChipBottomSheetState();
}

class _AddChipBottomSheetState extends State<AddChipBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.existingOptions;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.existingOptions;
      } else {
        _filteredOptions = widget.existingOptions
            .where((opt) => opt.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _submit(String value) {
    if (value.trim().isNotEmpty) {
      widget.onAdd(value.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              onChanged: _filterOptions,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Type or select...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check, color: AppColors.primary),
                  onPressed: () => _submit(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredOptions.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredOptions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final option = _filteredOptions[index];
                    return ListTile(
                      title: Text(option, style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () => _submit(option),
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('No options found. Type to add a new one.'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
