import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/admin_bean_edit_bloc.dart';
import 'bloc/admin_bean_edit_event.dart';
import 'repository/admin_bean_edit_repository.dart';
import 'widget/admin_bean_edit_view.dart';

class AdminBeanEditPage extends StatelessWidget {
  final String roasteryId;
  final String? beanId; // null means Add mode

  const AdminBeanEditPage({
    super.key,
    required this.roasteryId,
    this.beanId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBeanEditBloc(
        repository: AdminBeanEditRepository(),
      )..add(LoadBean(roasteryId: roasteryId, beanId: beanId)),
      child: const AdminBeanEditView(),
    );
  }
}
