import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/widgets/coming_soon_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/jelajahi_ukm/presentation/screens/feed_screen.dart';
import 'features/jelajahi_ukm/presentation/screens/main_shell_screen.dart';
import 'features/jelajahi_ukm/presentation/screens/notification_screen.dart';
import 'features/jelajahi_ukm/presentation/screens/ukm_detail_screen.dart';
import 'models/ukm.dart';
import 'theme/app_theme.dart';

class UkmHubApp extends StatelessWidget {
  const UkmHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UKM Hub Unand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) =>
            const ComingSoonScreen(title: 'Aktivasi Akun'),
        AppRoutes.home: (_) => const MainShellScreen(initialIndex: 0),
        AppRoutes.jelajahiUkm: (_) => const MainShellScreen(initialIndex: 1),
        AppRoutes.feed: (_) => const FeedScreen(showBottomNav: false),
        AppRoutes.notifications: (_) => const NotificationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.ukmDetail) {
          final ukm = settings.arguments as Ukm?;
          if (ukm != null) {
            return MaterialPageRoute(
              builder: (_) => UkmDetailScreen(ukm: ukm),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
