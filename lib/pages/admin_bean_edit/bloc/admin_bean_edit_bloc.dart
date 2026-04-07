import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/bean_model.dart';
import '../repository/admin_bean_edit_repository.dart';
import 'admin_bean_edit_event.dart';
import 'admin_bean_edit_state.dart';

class AdminBeanEditBloc extends Bloc<AdminBeanEditEvent, AdminBeanEditState> {
  final AdminBeanEditRepository repository;

  AdminBeanEditBloc({required this.repository})
      : super(const AdminBeanEditState()) {
    on<LoadBean>(_onLoadBean);
    on<UpdateBeanField>(_onUpdateBeanField);
    on<SaveBean>(_onSaveBean);
    on<DeleteBean>(_onDeleteBean);
  }

  Future<void> _onLoadBean(
    LoadBean event,
    Emitter<AdminBeanEditState> emit,
  ) async {
    emit(state.copyWith(status: AdminBeanEditStatus.loading));
    try {
      if (event.beanId == null) {
        // New bean — create empty template
        final empty = Bean.empty(event.roasteryId);
        emit(state.copyWith(
          status: AdminBeanEditStatus.loaded,
          bean: empty,
          isNew: true,
        ));
      } else {
        final bean = await repository.getBean(event.beanId!);
        emit(state.copyWith(
          status: AdminBeanEditStatus.loaded,
          bean: bean,
          isNew: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanEditStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateBeanField(
    UpdateBeanField event,
    Emitter<AdminBeanEditState> emit,
  ) {
    if (state.bean == null) return;
    final b = state.bean!;

    Bean updated;
    switch (event.field) {
      case 'cleanName':
        updated = b.copyWith(cleanName: event.value as String);
        break;
      case 'status':
        updated = b.copyWith(status: event.value as String);
        break;
      case 'origin':
        updated = b.copyWith(origin: event.value as String);
        break;
      case 'process':
        updated = b.copyWith(process: event.value as String);
        break;
      case 'roastLevel':
        updated = b.copyWith(roastLevel: event.value as String);
        break;
      case 'altitude':
        updated = b.copyWith(altitude: event.value as String);
        break;
      case 'variety':
        updated = b.copyWith(variety: event.value as List<String>);
        break;
      case 'notes':
        updated = b.copyWith(notes: event.value as List<String>);
        break;
      case 'variants':
        updated = b.copyWith(variants: event.value as Map<String, BeanVariant>);
        break;
      case 'imageUrl':
        updated = b.copyWith(imageUrl: event.value as String);
        break;
      case 'description':
        updated = b.copyWith(description: event.value as String);
        break;
      default:
        updated = b;
    }

    emit(state.copyWith(
      status: AdminBeanEditStatus.loaded,
      bean: updated,
      errorMessage: null,
    ));
  }

  Future<void> _onSaveBean(
    SaveBean event,
    Emitter<AdminBeanEditState> emit,
  ) async {
    if (state.bean == null) return;
    final b = state.bean!;

    // Validation
    if (b.cleanName.trim().isEmpty) {
      emit(state.copyWith(
        status: AdminBeanEditStatus.error,
        errorMessage: 'Name cannot be empty.',
      ));
      return;
    }

    // Generate fingerprint if new
    Bean toSave = b;
    if (state.isNew && b.fingerprint.isEmpty) {
      final fingerprint = '${b.roasteryId}_${_slugify(b.cleanName)}';
      toSave = b.copyWith(fingerprint: fingerprint);
    }

    emit(state.copyWith(status: AdminBeanEditStatus.saving));
    try {
      final saved = await repository.saveBean(toSave);
      emit(state.copyWith(
        status: AdminBeanEditStatus.success,
        bean: saved,
        isNew: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanEditStatus.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteBean(
    DeleteBean event,
    Emitter<AdminBeanEditState> emit,
  ) async {
    if (state.bean == null || state.isNew) return;
    emit(state.copyWith(status: AdminBeanEditStatus.saving));
    try {
      await repository.deleteBean(state.bean!.id);
      emit(state.copyWith(status: AdminBeanEditStatus.deleted));
    } catch (e) {
      emit(state.copyWith(
        status: AdminBeanEditStatus.error,
        errorMessage: 'Failed to delete: ${e.toString()}',
      ));
    }
  }

  String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
