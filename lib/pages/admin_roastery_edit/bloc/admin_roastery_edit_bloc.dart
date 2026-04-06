import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/roastery.dart';
import '../repository/admin_roastery_edit_repository.dart';
import 'admin_roastery_edit_event.dart';
import 'admin_roastery_edit_state.dart';

class AdminRoasteryEditBloc extends Bloc<AdminRoasteryEditEvent, AdminRoasteryEditState> {
  final AdminRoasteryEditRepository repository;

  AdminRoasteryEditBloc({required this.repository}) : super(const AdminRoasteryEditState()) {
    on<LoadRoastery>(_onLoadRoastery);
    on<UpdateRoasteryField>(_onUpdateRoasteryField);
    on<SaveRoastery>(_onSaveRoastery);
    on<DeleteRoastery>(_onDeleteRoastery);
  }

  Future<void> _onLoadRoastery(LoadRoastery event, Emitter<AdminRoasteryEditState> emit) async {
    emit(state.copyWith(status: AdminRoasteryEditStatus.loading));
    try {
      final roastery = await repository.getRoastery(event.id);
      emit(state.copyWith(
        status: AdminRoasteryEditStatus.loaded,
        roastery: roastery,
        isNew: event.id == null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: e.toString()));
    }
  }

  void _onUpdateRoasteryField(UpdateRoasteryField event, Emitter<AdminRoasteryEditState> emit) {
    if (state.roastery == null) return;
    final r = state.roastery!;
    
    Roastery updatedRoastery;
    
    if (['instagram', 'tokopedia', 'shopee', 'website'].contains(event.field)) {
      final updatedLinks = Map<String, String>.from(r.socialLinks ?? {});
      if (event.value.toString().trim().isEmpty) {
        updatedLinks.remove(event.field);
      } else {
        updatedLinks[event.field] = event.value;
      }
      updatedRoastery = Roastery(
        id: r.id, name: r.name, city: r.city, beanCount: r.beanCount,
        isActive: r.isActive, bio: r.bio, logoUrl: r.logoUrl,
        socialLinks: updatedLinks,
      );
    } else {
      updatedRoastery = Roastery(
        id: r.id,
        name: event.field == 'name' ? event.value : r.name,
        city: event.field == 'city' ? event.value : r.city,
        beanCount: r.beanCount,
        isActive: r.isActive,
        bio: event.field == 'bio' ? event.value : r.bio,
        logoUrl: event.field == 'logoUrl' ? event.value : r.logoUrl,
        socialLinks: r.socialLinks,
      );
    }

    emit(state.copyWith(
      status: AdminRoasteryEditStatus.loaded, 
      roastery: updatedRoastery,
      errorMessage: null, // Clear error on change
    ));
  }

  Future<void> _onSaveRoastery(SaveRoastery event, Emitter<AdminRoasteryEditState> emit) async {
    if (state.roastery == null) return;
    final r = state.roastery!;
    
    // Validation
    if (r.name.trim().isEmpty) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: "Name cannot be empty."));
      return;
    }
    if (r.city.trim().isEmpty) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: "City must be selected."));
      return;
    }
    
    final hasSocialLink = (r.socialLinks?.values.where((v) => v.trim().isNotEmpty).length ?? 0) > 0;
    if (!hasSocialLink) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: "At least one social media link must be filled."));
      return;
    }

    emit(state.copyWith(status: AdminRoasteryEditStatus.saving));
    try {
      await repository.saveRoastery(r);
      emit(state.copyWith(status: AdminRoasteryEditStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: "Failed to save: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteRoastery(DeleteRoastery event, Emitter<AdminRoasteryEditState> emit) async {
    if (state.roastery == null || state.isNew) return;
    emit(state.copyWith(status: AdminRoasteryEditStatus.saving));
    try {
      await repository.deleteRoastery(state.roastery!.id);
      emit(state.copyWith(status: AdminRoasteryEditStatus.deleted));
    } catch (e) {
      emit(state.copyWith(status: AdminRoasteryEditStatus.error, errorMessage: "Failed to delete: ${e.toString()}"));
    }
  }
}
