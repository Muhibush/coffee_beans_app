import 'package:coffee_beans_app/utils/design_system/app_theme_sage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:coffee_beans_app/utils/router/app_router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const CoffeeBeansApp());
}

/// Root Application widget for Coffee Beans App.
/// Orchestrates the global theme and routing configuration.
class CoffeeBeansApp extends StatelessWidget {
  const CoffeeBeansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coffee Beans App',
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,
      // theme: AppThemeForest.lightTheme,
      theme: AppThemeSage.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
