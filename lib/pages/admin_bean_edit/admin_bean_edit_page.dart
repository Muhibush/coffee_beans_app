import 'package:flutter/material.dart';
import 'package:coffee_beans_app/pages/admin_bean_edit/widget/admin_bean_edit_view.dart';

class AdminBeanEditPage extends StatelessWidget {
  final String roasteryId;
  final String? beanId; // If null, means Add mode. Otherwise edit mode.

  const AdminBeanEditPage({
    super.key,
    required this.roasteryId,
    this.beanId,
  });

  @override
  Widget build(BuildContext context) {
    // In the future, wrap this with BLoC Provider.
    // For now, depending on beanId, show empty form or prefilled form.
    final bool isEditMode = beanId != null;

    if (!isEditMode) {
      return const AdminBeanEditView(
        isEditMode: false,
      );
    }

    // Dummy data for Edit Mode view preview
    return AdminBeanEditView(
      isEditMode: true,
      initialName: 'Watermelon Smash',
      initialStatus: 'Draft',
      initialOrigin: 'Java',
      initialProcess: 'Anaerobic Natural',
      initialRoast: 'Light',
      initialAltitude: '1500 masl',
      initialVarieties: const ['Mix Variety'],
      initialNotes: const ['Berry', 'Strawberry', 'Melon', 'Orange', 'Watermelon'],
      initialImageUrl: 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      initialVariants: [
        VariantUiModel(
          weight: '100g', 
          price: 'Rp 96.570', 
          url: 'https://tokopedia.link/...',
        ),
      ],
    );
  }
}
