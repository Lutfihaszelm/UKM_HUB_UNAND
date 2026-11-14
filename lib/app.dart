import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

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
