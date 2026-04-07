import 'package:equatable/equatable.dart';

abstract class AdminBeanEditEvent extends Equatable {
  const AdminBeanEditEvent();

  @override
  List<Object?> get props => [];
}

/// Load a bean by id, or create empty template for new bean.
class LoadBean extends AdminBeanEditEvent {
  final String roasteryId;
  final String? beanId; // null = new bean

  const LoadBean({required this.roasteryId, this.beanId});

  @override
  List<Object?> get props => [roasteryId, beanId];
}

/// Update a single field on the bean being edited.
class UpdateBeanField extends AdminBeanEditEvent {
  final String field;
  final dynamic value;

  const UpdateBeanField(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

/// Save the current bean to Supabase.
class SaveBean extends AdminBeanEditEvent {}

/// Delete the current bean.
class DeleteBean extends AdminBeanEditEvent {}
