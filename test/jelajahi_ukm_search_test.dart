import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/features/jelajahi_ukm/application/jelajahi_ukm_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/ukm_dummy_data.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/jelajahi_ukm_screen.dart';


void main() {
  group('Jelajahi UKM – search/filter logic', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('default query is empty and shows all 20 UKM', () {
      final query = container.read(searchQueryProvider);
      final list = container.read(filteredUkmListProvider);

      expect(query, '');
      expect(list.length, 20);
      expect(list, kDummyUkmList);
    });

    test('whitespace-only query shows all organizations', () {
      container.read(searchQueryProvider.notifier).update('   ');
      final list = container.read(filteredUkmListProvider);

      expect(list.length, 20);
    });

    test('case-insensitive search filters correctly', () {
      container.read(searchQueryProvider.notifier).update('neo');
      final list = container.read(filteredUkmListProvider);

      expect(list.length, 1);
      expect(list.first.name, 'Neo Telemetri');
    });

    test('search with mixed case returns match', () {
      container.read(searchQueryProvider.notifier).update('MAPALA');
      final list = container.read(filteredUkmListProvider);

      expect(list.length, 1);
      expect(list.first.name, 'MAPALA UNAND');
    });

    test('partial match "ukm" returns 5 results', () {
      // "ukm" matches: UKM Seni (UKS), UKM Olahraga (UKO),
      // UKM PHP, UKM Penalaran, UKM PIKA
      container.read(searchQueryProvider.notifier).update('ukm');
      final list = container.read(filteredUkmListProvider);

      expect(list.length, 5);
      expect(
        list.map((u) => u.name).toList(),
        [
          'UKM Seni (UKS)',
          'UKM Olahraga (UKO)',
          'UKM PHP',
          'UKM Penalaran',
          'UKM PIKA',
        ],
      );
    });

    test('unmatched query returns empty list', () {
      container.read(searchQueryProvider.notifier).update('xyznonexistent');
      final list = container.read(filteredUkmListProvider);

      expect(list.isEmpty, true);
    });

    test('clearing query restores all organizations', () {
      // First filter to a subset
      container.read(searchQueryProvider.notifier).update('kopma');
      expect(container.read(filteredUkmListProvider).length, 1);

      // Clear query
      container.read(searchQueryProvider.notifier).update('');
      expect(container.read(filteredUkmListProvider).length, 20);
    });

    test('query with surrounding whitespace is trimmed', () {
      container.read(searchQueryProvider.notifier).update('  pandekar  ');
      final list = container.read(filteredUkmListProvider);

      expect(list.length, 1);
      expect(list.first.name, 'Pandekar');
    });

    test('search for "andalas" returns multiple matches', () {
      container.read(searchQueryProvider.notifier).update('andalas');
      final list = container.read(filteredUkmListProvider);

      // Matches: UKPM Genta Andalas, Andalas Sinematografi,
      // ADS (Andalas Debating Society)
      expect(list.length, 3);
      expect(
        list.map((u) => u.name).toList(),
        [
          'UKPM Genta Andalas',
          'Andalas Sinematografi',
          'ADS (Andalas Debating Society)',
        ],
      );
    });

    test('dataset contains exactly 20 UKM with valid descriptions and colors', () {
      expect(kDummyUkmList.length, 20);
      for (final ukm in kDummyUkmList) {
        expect(ukm.name.isNotEmpty, true);
        expect(ukm.description.length, greaterThan(30));
        expect(ukm.icon, isNotNull);
        expect(ukm.color, isNotNull);
      }
    });
  });

  group('Jelajahi UKM – UI & responsiveness', () {
    testWidgets('renders all cards with long descriptions without overflow on phone screen',
        (tester) async {
      // Set typical compact mobile screen size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JelajahiUkmScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and search bar exist
      expect(find.text('Jelajahi UKM'), findsOneWidget);
      expect(find.text('20 UKM'), findsOneWidget);

      // First items are displayed
      expect(find.text('UKPM Genta Andalas'), findsOneWidget);
      expect(find.textContaining('Jurnalis kampus'), findsOneWidget);

      // Scroll to the end to ensure all 20 cards render cleanly with zero overflow
      await tester.scrollUntilVisible(
        find.text('Menwa (Resimen Mahasiswa)'),
        300,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Menwa (Resimen Mahasiswa)'), findsOneWidget);
      expect(find.textContaining('disiplin militer'), findsOneWidget);
    });

    testWidgets('empty state renders without overflow when keyboard is open',
        (tester) async {
      // Simulate phone screen with keyboard open (height restricted to 350)
      tester.view.physicalSize = const Size(360, 350);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JelajahiUkmScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type an unmatched search term like in the user's screenshot
      await tester.enterText(find.byType(TextField), 'jdjdj');
      await tester.pumpAndSettle();

      expect(find.text('0 UKM'), findsOneWidget);

      // Scroll to reveal the empty state feedback smoothly without overflow
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('UKM tidak ditemukan'), findsOneWidget);
      expect(find.text('Coba kata kunci lain.'), findsOneWidget);
    });
  });
}


