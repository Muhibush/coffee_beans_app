import 'package:equatable/equatable.dart';
import '../../../model/bean_model.dart';

enum AdminBeanEditStatus { initial, loading, loaded, saving, success, error, deleted }

class AdminBeanEditState extends Equatable {
  final AdminBeanEditStatus status;
  final Bean? bean;
  final bool isNew;
  final String? errorMessage;

  const AdminBeanEditState({
    this.status = AdminBeanEditStatus.initial,
    this.bean,
    this.isNew = false,
    this.errorMessage,
  });

  AdminBeanEditState copyWith({
    AdminBeanEditStatus? status,
    Bean? bean,
    bool? isNew,
    String? errorMessage,
  }) {
    return AdminBeanEditState(
      status: status ?? this.status,
      bean: bean ?? this.bean,
      isNew: isNew ?? this.isNew,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bean, isNew, errorMessage];
}
