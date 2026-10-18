import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/core/routing/app_routes.dart';
import 'package:ukm_hub/screens/home_screen.dart';
import 'package:ukm_hub/utils/validators.dart';

/// Test integrasi: Home (Modul 2) -> tab UKM (Modul 1) dan Home -> Oprec (Modul 3).
/// Font test (Ahem) jauh lebih lebar dari font asli, jadi peringatan overflow
/// layout diabaikan di test ini; yang diuji adalah navigasi antarmodul.
void _ignoreOverflow() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
}

Widget _app() => ProviderScope(
      child: MaterialApp(
        home: const HomeScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
  });

  testWidgets('Tab UKM menampilkan Jelajahi UKM milik Modul 1', (tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(seconds: 3)); // tunggu loading dummy

    await tester.tap(find.text('UKM'));
    await tester.pumpAndSettle();

    expect(find.text('Jelajahi UKM'), findsOneWidget);
    expect(find.text('20 UKM'), findsOneWidget);
  });

  testWidgets('Kartu oprec di Home membuka Detail Oprec lalu Form (Modul 3)',
      (tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(seconds: 3));

    final oprecTitle = find.text('Join AIESEC 2026');
    await tester.scrollUntilVisible(oprecTitle, 300,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lihat Detail').first);
    await tester.tap(find.text('Lihat Detail').first);
    await tester.pumpAndSettle();

    expect(find.text('Open Recruitment'), findsWidgets);
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Form Pendaftaran'), findsOneWidget);
  });

  group('Validators form oprec', () {
    test('nama, NIM, motivasi', () {
      expect(Validators.name('ab'), 'Minimal 3 karakter (sekarang 2)');
      expect(Validators.nim('12345'), 'NIM harus 10 digit angka');
      expect(Validators.nim('2411522010'), isNull);
      expect(Validators.motivation('pendek'), 'Minimal 20 karakter (sekarang 6)');
    });
  });
}
