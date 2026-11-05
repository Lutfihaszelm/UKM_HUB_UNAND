import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukm_hub/features/jelajahi_ukm/application/feed_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/follow_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/jelajahi_ukm_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/notification_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/post_dummy_data.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/ukm_dummy_data.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/feed_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/jelajahi_ukm_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/main_shell_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/notification_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/ukm_detail_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/widgets/post_card.dart';
import 'package:ukm_hub/models/ukm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Modul 1: FR-01 â€” Direktori & Pencarian UKM', () {
    test('1. Daftar 20 UKM tampil saat query kosong', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final list = container.read(filteredUkmListProvider);
      expect(list.length, 20);
      expect(list, equals(kDummyUkmList));
    });

    test('2. Pencarian case-insensitive dan penanganan spasi (whitespace)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Whitespace trimming
      container.read(searchQueryProvider.notifier).update('   neo   ');
      var list = container.read(filteredUkmListProvider);
      expect(list.length, 1);
      expect(list.first.name, 'Neo Telemetri');

      // Case-insensitive
      container.read(searchQueryProvider.notifier).update('MAPALA');
      list = container.read(filteredUkmListProvider);
      expect(list.length, 1);
      expect(list.first.name, 'MAPALA UNAND');
    });

    test('3. Empty state saat kata kunci tidak cocok dan pulih saat di-reset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).update('tidak_ada_ukm_ini');
      expect(container.read(filteredUkmListProvider).isEmpty, true);

      // Reset
      container.read(searchQueryProvider.notifier).update('');
      expect(container.read(filteredUkmListProvider).length, 20);
    });
  });

  group('Modul 1: FR-02 & FR-03 â€” Detail UKM & Follow/Unfollow', () {
    test('4. Model UKM memiliki atribut lengkap (id, nama, kategori, deskripsi, kontak)', () {
      for (final ukm in kDummyUkmList) {
        expect(ukm.id.isNotEmpty, true);
        expect(ukm.name.isNotEmpty, true);
        expect(ukm.kategori.isNotEmpty, true);
        expect(ukm.description.isNotEmpty, true);
        expect(ukm.icon, isNotNull);
        expect(ukm.color, isNotNull);
      }
    });

    test('5. Follow dan Unfollow mengubah state dan tersimpan di SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state is empty
      final initial = await container.read(followedUkmIdsProvider.future);
      expect(initial, isEmpty);

      // Follow UKM
      await container.read(followedUkmIdsProvider.notifier).toggleFollow('ukm-07');
      final afterFollow = container.read(followedUkmIdsProvider).value;
      expect(afterFollow?.contains('ukm-07'), isTrue);

      // Verify persistence in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('followed_ukm_ids'), contains('ukm-07'));

      // Unfollow UKM
      await container.read(followedUkmIdsProvider.notifier).toggleFollow('ukm-07');
      final afterUnfollow = container.read(followedUkmIdsProvider).value;
      expect(afterUnfollow?.contains('ukm-07'), isFalse);
      expect(prefs.getStringList('followed_ukm_ids')?.contains('ukm-07') ?? false, isFalse);
    });
  });

  group('Modul 1: FR-04 & FR-05 â€” Feed Informasi & Filter / Pencarian', () {
    test('6. Feed seluruh UKM dan feed personal berdasarkan UKM diikuti', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // All posts feed by default
      final allPosts = container.read(filteredPostListProvider);
      expect(allPosts.length, kDummyPostList.length);

      // Follow Neo Telemetri (ukm-07)
      await container.read(followedUkmIdsProvider.notifier).toggleFollow('ukm-07');

      // Turn on personal feed only
      container.read(personalFeedOnlyProvider.notifier).set(true);
      final personalPosts = container.read(filteredPostListProvider);

      expect(personalPosts.isNotEmpty, true);
      for (final post in personalPosts) {
        expect(post.ukmId, 'ukm-07');
      }
    });

    test('7. Filter kategori, filter UKM spesifik, dan pencarian keyword feed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Filter category 'event'
      container.read(selectedCategoryProvider.notifier).select('event');
      var filtered = container.read(filteredPostListProvider);
      expect(filtered.every((p) => p.kategori == 'event'), isTrue);

      // Filter UKM 'ukm-01'
      container.read(selectedCategoryProvider.notifier).select(null);
      container.read(selectedUkmFilterProvider.notifier).select('ukm-01');
      filtered = container.read(filteredPostListProvider);
      expect(filtered.every((p) => p.ukmId == 'ukm-01'), isTrue);

      // Pencarian keyword pada feed (FR-05)
      container.read(selectedUkmFilterProvider.notifier).select(null);
      container.read(postSearchQueryProvider.notifier).update('workshop');
      filtered = container.read(filteredPostListProvider);
      expect(filtered.isNotEmpty, true);
      for (final p in filtered) {
        final match = p.title.toLowerCase().contains('workshop') ||
            p.content.toLowerCase().contains('workshop') ||
            p.ukmName.toLowerCase().contains('workshop');
        expect(match, isTrue);
      }
    });

    test('8. Reset filter mengembalikan semua postingan', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedCategoryProvider.notifier).select('lomba');
      container.read(selectedUkmFilterProvider.notifier).select('ukm-07');
      container.read(personalFeedOnlyProvider.notifier).set(true);
      container.read(postSearchQueryProvider.notifier).update('workshop');

      // Reset
      container.read(selectedCategoryProvider.notifier).select(null);
      container.read(selectedUkmFilterProvider.notifier).select(null);
      container.read(personalFeedOnlyProvider.notifier).set(false);
      container.read(postSearchQueryProvider.notifier).clear();

      final resetPosts = container.read(filteredPostListProvider);
      expect(resetPosts.length, kDummyPostList.length);
    });
  });

  group('Modul 1: FR-13 â€” Notifikasi Postingan UKM yang Diikuti', () {
    test('9. Notifikasi hanya terbit untuk postingan dari UKM yang diikuti', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // No followed UKM -> no notifications
      var notifs = container.read(notificationListProvider);
      expect(notifs, isEmpty);

      // Follow Neo Telemetri (ukm-07)
      await container.read(followedUkmIdsProvider.notifier).toggleFollow('ukm-07');
      notifs = container.read(notificationListProvider);

      expect(notifs.isNotEmpty, true);
      for (final n in notifs) {
        expect(n.ukmId, 'ukm-07');
      }

      // Unread count
      final unreadCount = container.read(unreadNotificationCountProvider);
      expect(unreadCount, notifs.length);

      // Mark single notification as read
      container.read(readNotificationIdsProvider.notifier).markRead(notifs.first.id);
      expect(container.read(unreadNotificationCountProvider), notifs.length - 1);
    });
  });

  group('Modul 1: Widget & Integration Tests', () {
    testWidgets('10. Membuka detail UKM dari kartu di direktori', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JelajahiUkmScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on UKPM Genta Andalas
      await tester.tap(find.text('UKPM Genta Andalas'));
      await tester.pumpAndSettle();

      // Verified on UkmDetailScreen
      expect(find.text('Tentang'), findsOneWidget);
      expect(find.text('Kategori: '), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('11. Toggle Follow di UkmDetailScreen mengubah label tombol', (tester) async {
      const sampleUkm = Ukm(
        id: 'ukm-07',
        name: 'Neo Telemetri',
        description: 'Unit kegiatan mahasiswa bidang IT',
        icon: Icons.computer_rounded,
        color: Color(0xFF0D9488),
        kategori: 'Teknologi',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UkmDetailScreen(ukm: sampleUkm),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Follow'), findsOneWidget);

      // Tap follow
      await tester.tap(find.text('Follow'));
      await tester.pumpAndSettle();

      expect(find.text('Following'), findsOneWidget);

      // Tap unfollow
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('12. FeedScreen merender postingan, pencarian, dan chip kategori', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Semua'), findsWidgets);
      expect(find.text('Event'), findsWidgets);
      expect(find.byType(PostCard), findsWidgets);
    });

    testWidgets('13. NotificationScreen menampilkan empty state saat belum follow UKM', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
    });

    testWidgets('14. MainShellScreen navigasi tab dan akses notifikasi via lonceng Home', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainShellScreen(initialIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts on Tab 0 (Home)
      expect(find.text('UKM UNAND'), findsOneWidget);
      expect(find.text('Postingan'), findsOneWidget);

      // Switch to Tab 1 (UKM)
      await tester.tap(find.byIcon(Icons.apartment_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Jelajahi UKM'), findsOneWidget);
      expect(find.text('Daftar Organisasi Kampus'), findsOneWidget);

      // Menu 3 (Slot Open Recruitment) dinonaktifkan sementara: ketuk tidak membuka notifikasi / halaman lain
      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Jelajahi UKM'), findsOneWidget);

      // Kembali ke Tab 0 (Home)
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('UKM UNAND'), findsOneWidget);

      // Buka Notifikasi khusus via ikon lonceng Home Screen (satu-satunya akses)
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Belum Ada Notifikasi'), findsOneWidget);

      // Tombol kembali kembali ke Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('UKM UNAND'), findsOneWidget);
    });
  });
}