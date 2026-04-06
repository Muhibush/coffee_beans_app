import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/admin_roastery_edit_bloc.dart';
import 'bloc/admin_roastery_edit_event.dart';
import 'repository/admin_roastery_edit_repository.dart';
import 'widget/admin_roastery_edit_view.dart';

class AdminRoasteryEditPage extends StatelessWidget {
  final String id;

  const AdminRoasteryEditPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // If id == 'new', we treat it as a new creation
    final actualId = id == 'new' ? null : id;

    return BlocProvider(
      create: (context) => AdminRoasteryEditBloc(
        repository: AdminRoasteryEditRepository(),
      )..add(LoadRoastery(actualId)),
      child: const AdminRoasteryEditView(),
    );
  }
}
