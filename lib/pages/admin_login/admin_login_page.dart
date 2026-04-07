import 'package:flutter/material.dart';
import 'widget/admin_login_view.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is provided at the app root level (main.dart)
    return const AdminLoginView();
  }
}
