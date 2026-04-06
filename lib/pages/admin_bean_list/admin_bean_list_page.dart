import 'package:flutter/material.dart';
import 'widget/admin_bean_list_view.dart';

class AdminBeanListPage extends StatelessWidget {
  const AdminBeanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In the future: Wrap with BlocProvider for AdminBeanListBloc
    return const AdminBeanListView();
  }
}
