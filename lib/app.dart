import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'theme/app_theme.dart';

class UkmHubApp extends StatelessWidget {
  const UkmHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UKM Hub Unand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
