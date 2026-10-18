import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/not_found_screen.dart';
import '../../screens/detail_screen.dart';
import '../../screens/catatan_form_screen.dart';
import '../../screens/post_detail_screen.dart';
import '../../models/ukm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/oprec/data/oprec_providers.dart';
import '../../features/oprec/models/oprec_post.dart';
import '../../features/oprec/presentation/oprec_theme.dart';
import '../../features/oprec/presentation/screens/oprec_detail_screen.dart';
import '../widgets/coming_soon_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';
  static const String postDetail = '/post-detail';
  static const String oprecDetail = '/oprec-detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const ComingSoonScreen(title: 'Aktivasi Akun'),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Ukm) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      case oprecDetail:
        final args = settings.arguments;
        if (args is OprecPost) {
          return MaterialPageRoute<void>(
            builder: (_) => Consumer(
              builder: (context, ref, _) => Theme(
                data: buildOprecTheme(),
                child: OprecDetailScreen(
                  post: args,
                  repository: ref.read(oprecRepositoryProvider),
                ),
              ),
            ),
            settings: settings,
          );
        }
        return null;
      case postDetail:
        return MaterialPageRoute<void>(
          builder: (_) => const PostDetailScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
