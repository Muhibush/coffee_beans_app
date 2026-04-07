import 'package:go_router/go_router.dart';
import 'package:coffee_beans_app/pages/design_system/design_system_page.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/admin_dashboard_page.dart';
import 'package:coffee_beans_app/pages/admin_roastery_edit/admin_roastery_edit_page.dart';
import 'package:coffee_beans_app/pages/admin_bean_list/admin_bean_list_page.dart';
import 'package:coffee_beans_app/pages/admin_bean_edit/admin_bean_edit_page.dart';

/// Central router configuration for the Coffee Beans App.
/// Handles all public and admin-level navigation logic.
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/admin/roastery',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/admin/roastery',
      ),
      GoRoute(
        path: '/design-system',
        builder: (context, state) => const DesignSystemPage(),
      ),
      GoRoute(
        path: '/admin/roastery',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/roastery/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'new';
          return AdminRoasteryEditPage(id: id);
        },
      ),
      GoRoute(
        path: '/admin/roastery/:id/beans',
        builder: (context, state) {
          return const AdminBeanListPage();
        },
      ),
      GoRoute(
        path: '/admin/roastery/:roasteryId/beans/:beanId',
        builder: (context, state) {
          final roasteryId = state.pathParameters['roasteryId']!;
          final beanId = state.pathParameters['beanId'];
          return AdminBeanEditPage(
            roasteryId: roasteryId,
            beanId: beanId == 'new' ? null : beanId,
          );
        },
      ),
    ],
  );
}
