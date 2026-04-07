import 'package:coffee_beans_app/utils/design_system/app_theme_sage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:coffee_beans_app/utils/router/app_router.dart';
import 'package:coffee_beans_app/pages/admin_login/bloc/auth_bloc.dart';
import 'package:coffee_beans_app/pages/admin_login/bloc/auth_event.dart';
import 'package:coffee_beans_app/pages/admin_login/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Load environment variables
  await dotenv.load(fileName: "env/.env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const CoffeeBeansApp());
}

/// Root Application widget for Coffee Beans App.
/// Orchestrates the global theme and routing configuration.
class CoffeeBeansApp extends StatelessWidget {
  const CoffeeBeansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        repository: AuthRepository(),
      )..add(AuthStatusChecked()),
      child: MaterialApp.router(
        title: 'Coffee Beans App',
        debugShowCheckedModeBanner: false,
        // theme: AppTheme.lightTheme,
        // theme: AppThemeForest.lightTheme,
        theme: AppThemeSage.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
