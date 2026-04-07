import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_provider/scraper_service.dart';
import 'bloc/admin_bean_list_bloc.dart';
import 'bloc/admin_bean_list_event.dart';
import 'repository/admin_bean_list_repository.dart';
import 'widget/admin_bean_list_view.dart';

class AdminBeanListPage extends StatelessWidget {
  final String roasteryId;

  const AdminBeanListPage({super.key, required this.roasteryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBeanListBloc(
        repository: AdminBeanListRepository(),
        scraperService: ScraperService(),
      )..add(LoadBeans(roasteryId)),
      child: AdminBeanListView(roasteryId: roasteryId),
    );
  }
}
