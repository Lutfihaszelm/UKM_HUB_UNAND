import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/app.dart';

void main() {
  testWidgets('Splash screen navigates to Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    expect(find.text('UKM HUB UNAND'), findsNothing); // rendered via RichText spans
    expect(find.textContaining('Menghubungkan ke Kampus'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Masuk ke UKM Hub'), findsOneWidget);
    expect(find.text('Email Mahasiswa / NIM'), findsOneWidget);
  });
}
