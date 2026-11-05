import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/app.dart';
import 'package:ukm_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:ukm_hub/features/home/presentation/widgets/home_post_card.dart';

void main() {
  group('Home Screen – Rendering and Navigation', () {
    testWidgets('App opens to Home Screen with greeting and components',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Home screen header greeting
      expect(find.textContaining('Halo'), findsOneWidget);
      expect(find.text('Siap menjelajahi UKM di UNAND?'), findsOneWidget);

      // Search bar
      expect(find.text('Jelajahi UKM baru'), findsOneWidget);

      // UKM section
      expect(find.text('UKM UNAND'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);

      // Postingan section
      expect(find.text('Postingan'), findsOneWidget);
      expect(find.byType(HomePostCard), findsWidgets);
    });

    testWidgets('Home Screen navigates to Jelajahi UKM via "Lihat Semua"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Tap "Lihat Semua" to switch to UKM tab
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      // Should now see the Jelajahi UKM screen
      expect(find.text('Jelajahi UKM'), findsOneWidget);
      expect(find.text('Daftar Organisasi Kampus'), findsOneWidget);
    });

    testWidgets('Home Screen navigates to Jelajahi UKM via Search Bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Tap search bar
      await tester.tap(find.text('Jelajahi UKM baru'));
      await tester.pumpAndSettle();

      expect(find.text('Jelajahi UKM'), findsOneWidget);
    });

    testWidgets('Home Screen navigates to Jelajahi UKM via "UKM Lainnya"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Tap UKM Lainnya
      await tester.tap(find.text('UKM\nLainnya'));
      await tester.pumpAndSettle();

      expect(find.text('Jelajahi UKM'), findsOneWidget);
    });

    testWidgets('Home Screen opens UKM Detail when featured UKM is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Tap Neo Telemetri squircle
      await tester.tap(find.text('Neo\nTelemetri'));
      await tester.pumpAndSettle();

      // UkmDetailScreen should show
      expect(find.text('Neo Telemetri'), findsAtLeastNWidgets(1));
      expect(find.text('Tentang'), findsOneWidget);
    });

    testWidgets('Home Screen opens post detail modal when post card is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Scroll down to make post cards visible in viewport
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -450));
      await tester.pumpAndSettle();

      // Tap the post card link
      await tester.tap(find.text('Lihat Postingan >').first);
      await tester.pumpAndSettle();

      // Modal bottom sheet should show
      expect(find.textContaining('Kunjungi Profil'), findsOneWidget);
    });
  });

  group('FR-02: Detail Profil UKM Screen', () {
    testWidgets('Detail UKM displays complete profile data and back navigation works',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Open UKM detail from Home (Neo Telemetri)
      await tester.tap(find.text('Neo\nTelemetri'));
      await tester.pumpAndSettle();

      // Verify UKM Detail components
      expect(find.text('Detail Profil UKM'), findsOneWidget);
      expect(find.text('Neo Telemetri'), findsAtLeastNWidgets(1));
      expect(find.text('Teknologi'), findsAtLeastNWidgets(1));
      expect(find.text('Tentang'), findsOneWidget);
      expect(find.text('Detail Informasi'), findsOneWidget);
      expect(find.text('Kategori: '), findsOneWidget);
      expect(find.text('Kontak: '), findsOneWidget);
      expect(find.text('@neotelemetri'), findsOneWidget);
      expect(find.text('Universitas Andalas'), findsOneWidget);

      // Verify back navigation button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Should be back on Home Screen
      expect(find.text('UKM UNAND'), findsOneWidget);
    });

    testWidgets('Detail UKM opens correctly from Jelajahi UKM directory',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      // Switch to Jelajahi UKM tab
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      // Tap on UKPM Genta Andalas card
      await tester.tap(find.text('UKPM Genta Andalas'));
      await tester.pumpAndSettle();

      // Verify UKPM Genta Andalas profile detail
      expect(find.text('Detail Profil UKM'), findsOneWidget);
      expect(find.text('UKPM Genta Andalas'), findsAtLeastNWidgets(1));
      expect(find.text('Media'), findsAtLeastNWidgets(1));
      expect(find.text('@gentaandalas'), findsOneWidget);

      // Back navigation returns to Jelajahi UKM
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Jelajahi UKM'), findsOneWidget);
    });
  });

  group('Home Screen – Responsiveness on different screen sizes', () {
    testWidgets('renders cleanly without overflow on compact screen (360x640)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      expect(find.text('UKM UNAND'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on modern phone width (412x915)',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
      await tester.pumpAndSettle();

      expect(find.text('UKM UNAND'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Login screen – overflow and responsiveness', () {
    testWidgets(
        'renders cleanly without overflow on compact phone width (360x640)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke UKM Hub'), findsOneWidget);
      expect(find.text('Aktivasi Akun'), findsOneWidget);
      expect(find.text('Helpdesk IT Kampus'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'scrolls smoothly without overflow when keyboard is open (360x320)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 320);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke UKM Hub'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll down to reveal footer
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Aktivasi Akun'), findsOneWidget);
      expect(find.text('Helpdesk IT Kampus'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
