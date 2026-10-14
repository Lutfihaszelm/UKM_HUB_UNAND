import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/app.dart';
import 'package:ukm_hub/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('App opens directly to Jelajahi UKM screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));
    await tester.pumpAndSettle();

    expect(find.text('Jelajahi UKM'), findsOneWidget);
    expect(find.text('Daftar Organisasi Kampus'), findsOneWidget);
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
