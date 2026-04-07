import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'repository/auth_repository.dart';
import 'widget/admin_login_view.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        repository: AuthRepository(),
      )..add(AuthStatusChecked()),
      child: const AdminLoginView(),
    );
  }
}
