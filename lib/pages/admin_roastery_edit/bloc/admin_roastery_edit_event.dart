import 'package:equatable/equatable.dart';

abstract class AdminRoasteryEditEvent extends Equatable {
  const AdminRoasteryEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoastery extends AdminRoasteryEditEvent {
  final String? id;

  const LoadRoastery(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateRoasteryField extends AdminRoasteryEditEvent {
  final String field;
  final dynamic value;

  const UpdateRoasteryField(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class SaveRoastery extends AdminRoasteryEditEvent {}

class DeleteRoastery extends AdminRoasteryEditEvent {}
