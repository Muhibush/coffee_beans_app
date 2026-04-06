import 'package:flutter/material.dart';
import 'package:coffee_beans_app/theme/app_theme.dart';
import 'package:coffee_beans_app/pages/design_system_page.dart';
import 'package:coffee_beans_app/pages/admin_dashboard_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Beans App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Default home for public users — will be replaced with go_router later
      home: const DesignSystemPage(),
      routes: {
        // Admin dashboard — accessed via URL bypass from admin login
        '/admin/roastery': (context) => const AdminDashboardPage(),
        // Design system reference page
        '/design-system': (context) => const DesignSystemPage(),
      },
    );
  }
}
