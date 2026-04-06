import 'package:equatable/equatable.dart';
import '../../../model/roastery.dart';

enum AdminRoasteryEditStatus { initial, loading, loaded, saving, success, error, deleted }

class AdminRoasteryEditState extends Equatable {
  final AdminRoasteryEditStatus status;
  final Roastery? roastery;
  final String? errorMessage;
  final bool isNew;

  const AdminRoasteryEditState({
    this.status = AdminRoasteryEditStatus.initial,
    this.roastery,
    this.errorMessage,
    this.isNew = false,
  });

  AdminRoasteryEditState copyWith({
    AdminRoasteryEditStatus? status,
    Roastery? roastery,
    String? errorMessage,
    bool? isNew,
  }) {
    return AdminRoasteryEditState(
      status: status ?? this.status,
      roastery: roastery ?? this.roastery,
      errorMessage: errorMessage, // We don't ?? here to allow clearing error
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [status, roastery, errorMessage, isNew];
}
