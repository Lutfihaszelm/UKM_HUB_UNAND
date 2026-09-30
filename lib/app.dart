import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/widgets/coming_soon_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class UkmHubApp extends StatelessWidget {
  const UkmHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UKM Hub Unand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
