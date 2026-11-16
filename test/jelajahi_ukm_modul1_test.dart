import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukm_hub/features/jelajahi_ukm/application/feed_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/follow_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/notification_provider.dart';
import 'package:ukm_hub/features/jelajahi_ukm/application/repository_providers.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/notification_repository.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/post_dummy_data.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/post_repository.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/ukm_dummy_data.dart';
import 'package:ukm_hub/features/jelajahi_ukm/data/ukm_repository.dart';
import 'package:ukm_hub/features/jelajahi_ukm/models/notification_item.dart';
import 'package:ukm_hub/features/jelajahi_ukm/models/post.dart';
import 'package:ukm_hub/features/jelajahi_ukm/models/ukm.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/feed_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/notification_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/ukm_detail_screen.dart';
import 'package:ukm_hub/features/jelajahi_ukm/presentation/screens/ukm_post_detail_screen.dart';
import 'package:ukm_hub/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Modul 1 sesuai kontrak API', () {
    test('Ukm.fromJson membaca seluruh field kontrak', () {
      final ukm = Ukm.fromJson({
        'id': 'd4f1',
        'name': 'UKM Neo Telemetri',
        'description': 'UKM bidang teknologi dan riset.',
        'contact': 'neotelemetri@example.com',
        'logo_url': 'https://example.com/neo.png',
        'banner_url': null,
        'is_verified': true,
        'follower_count': 120,
        'followed_by_me': true,
        'has_open_oprec': true,
      });

      expect(ukm.id, 'd4f1');
      expect(ukm.name, 'UKM Neo Telemetri');
      expect(ukm.contact, 'neotelemetri@example.com');
      expect(ukm.logoUrl, 'https://example.com/neo.png');
      expect(ukm.isVerified, true);
      expect(ukm.followerCount, 120);
      expect(ukm.followedByMe, true);
      expect(ukm.hasOpenOprec, true);
      expect(ukm.toJson()['follower_count'], 120);
    });

    test('Post.fromJson membaca author, tag, dan lampiran', () {
      final post = Post.fromJson({
        'id': 'post-1',
        'category': 'event',
        'badge': 'Event Nasional',
        'ukm': {
          'id': 'ukm-07',
          'name': 'UKM Neo Telemetri',
          'logo_url': null,
          'is_verified': true,
        },
        'title': 'Neo Firetech 2026',
        'description': 'Ringkasan singkat.',
        'location': 'Limau Manis',
        'tags': ['#NeoFiretech', '#PrestasiKampus'],
        'banner_url': null,
        'like_count': 128,
        'comment_count': 24,
        'liked_by_me': false,
        'published_at': '2026-11-05T03:00:00Z',
        'content': 'Isi lengkap postingan.',
        'attachments': [
          {
            'id': 'att-1',
            'type': 'document',
            'name': 'panduan.pdf',
            'size_bytes': 245760,
            'url': 'https://example.com/panduan.pdf',
          },
        ],
      });

      expect(post.author.name, 'UKM Neo Telemetri');
      expect(post.author.isVerified, true);
      expect(post.tags.length, 2);
      expect(post.likeCount, 128);
      expect(post.attachments.single.name, 'panduan.pdf');
      expect(post.content, 'Isi lengkap postingan.');
      expect(post.publishedAt.toUtc().hour, 3);
    });

    test('NotificationItem.fromJson membaca tipe new_post', () {
      final item = NotificationItem.fromJson({
        'id': 'notif-1',
        'type': 'new_post',
        'title': 'Neo Telemetri memposting kabar baru',
        'body': 'Workshop Flutter',
        'ref_id': 'post-1',
        'post_id': 'post-1',
        'is_read': false,
        'created_at': '2026-11-07T02:00:00Z',
      });

      expect(item.type, NotificationType.newPost);
      expect(item.postId, 'post-1');
      expect(item.isRead, false);
      expect(item.copyWith(isRead: true).isRead, true);
    });
  });

  group('Follow UKM', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'followed_ukm_ids': <String>[]});
    });

    test('toggle follow menyimpan ke SharedPreferences', () async {
      final container = ProviderContainer(
        overrides: [
          ukmRepositoryProvider.overrideWithValue(
            const FakeUkmRepository(delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(followedUkmIdsProvider.future);
      expect(container.read(followedUkmIdsProvider).value, isEmpty);

      await container
          .read(followedUkmIdsProvider.notifier)
          .toggleFollow('ukm-07');

      expect(container.read(followedUkmIdsProvider).value, contains('ukm-07'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('followed_ukm_ids'), contains('ukm-07'));

      await container
          .read(followedUkmIdsProvider.notifier)
          .toggleFollow('ukm-07');
      expect(container.read(followedUkmIdsProvider).value, isEmpty);
    });

    test('jumlah pengikut menyesuaikan status follow lokal', () {
      expect(
        followerCountForDisplay(
          baseCount: 10,
          followedByMe: false,
          following: false,
        ),
        10,
      );
      expect(
        followerCountForDisplay(
          baseCount: 10,
          followedByMe: false,
          following: true,
        ),
        11,
      );
      expect(
        followerCountForDisplay(
          baseCount: 10,
          followedByMe: true,
          following: false,
        ),
        9,
      );
      expect(
        followerCountForDisplay(
          baseCount: 0,
          followedByMe: true,
          following: false,
        ),
        0,
      );
    });
  });

  group('Feed & notifikasi', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'followed_ukm_ids': <String>['ukm-07'],
      });
      container = ProviderContainer(
        overrides: [
          ukmRepositoryProvider.overrideWithValue(
            const FakeUkmRepository(delay: Duration.zero),
          ),
          postRepositoryProvider.overrideWithValue(
            const FakePostRepository(delay: Duration.zero),
          ),
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(delay: Duration.zero),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'scope following hanya menampilkan postingan UKM yang diikuti',
      () async {
        await container.read(followedUkmIdsProvider.future);

        final all = await container.read(feedPostsProvider.future);
        expect(all.length, 12);

        container.read(feedScopeProvider.notifier).select(FeedScope.following);
        final following = await container.read(feedPostsProvider.future);
        expect(following.length, 2);
        expect(following.every((post) => post.author.id == 'ukm-07'), true);

        container.read(selectedCategoryProvider.notifier).select('oprec');
        final oprec = await container.read(feedPostsProvider.future);
        expect(oprec.length, 1);
        expect(oprec.single.id, 'post-02');
      },
    );

    test('pencarian feed mencari judul dan isi postingan', () async {
      await container.read(followedUkmIdsProvider.future);

      container.read(postSearchQueryProvider.notifier).update('workshop');
      final result = await container.read(feedPostsProvider.future);

      expect(result.length, 1);
      expect(result.single.id, 'post-01');
    });

    test(
      'notifikasi hanya dari UKM yang diikuti dan bisa ditandai dibaca',
      () async {
        await container.read(followedUkmIdsProvider.future);
        final items = await container.read(notificationListProvider.future);

        expect(items.length, 2);
        expect(items.map((item) => item.postId).toSet(), {
          'post-01',
          'post-02',
        });
        expect(
          items.every((item) => item.type == NotificationType.newPost),
          true,
        );
        expect(container.read(unreadNotificationCountProvider), 1);

        await container
            .read(notificationListProvider.notifier)
            .markRead('notif-post-01');
        expect(container.read(unreadNotificationCountProvider), 0);

        await container.read(notificationListProvider.notifier).markAllRead();
        expect(
          container
              .read(notificationListProvider)
              .value!
              .every((item) => item.isRead),
          true,
        );

        // Refresh tidak boleh mengembalikan status belum dibaca.
        container.invalidate(notificationListProvider);
        final refreshed = await container.read(notificationListProvider.future);
        expect(refreshed.every((item) => item.isRead), true);
        expect(container.read(unreadNotificationCountProvider), 0);
      },
    );
  });

  group('Widget Modul 1', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'followed_ukm_ids': <String>['ukm-07'],
      });
    });

    Widget wrapWithProviders(Widget child) {
      return ProviderScope(
        overrides: [
          ukmRepositoryProvider.overrideWithValue(
            const FakeUkmRepository(delay: Duration.zero),
          ),
          postRepositoryProvider.overrideWithValue(
            const FakePostRepository(delay: Duration.zero),
          ),
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(delay: Duration.zero),
          ),
        ],
        child: child,
      );
    }

    void setPhoneSize(WidgetTester tester, {Size size = const Size(360, 640)}) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('detail UKM menampilkan header, kontak, dan tombol follow', (
      tester,
    ) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapWithProviders(
          MaterialApp(
            theme: AppTheme.light,
            home: UkmDetailScreen(
              ukm: kDummyUkmList.firstWhere((ukm) => ukm.id == 'ukm-07'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Neo Telemetri'), findsOneWidget);
      expect(find.text('Deskripsi'), findsOneWidget);
      expect(find.text('Postingan'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('@neotelemetri'), findsOneWidget);
      expect(find.text('neotelemetri@unand.ac.id'), findsOneWidget);
      expect(find.text('https://neotelemetri.com'), findsOneWidget);

      await tester.tap(find.text('Following'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('detail UKM menampilkan Deskripsi dan tab Postingan', (
      tester,
    ) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapWithProviders(
          MaterialApp(
            theme: AppTheme.light,
            home: UkmDetailScreen(
              ukm: kDummyUkmList.firstWhere((ukm) => ukm.id == 'ukm-07'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -420));
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Sejarah'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 420));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Postingan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Postingan'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
      await tester.pumpAndSettle();

      expect(find.text('Workshop Flutter & Dart 2026'), findsOneWidget);
      expect(find.text('Open Recruitment Neo Telemetri 2026'), findsOneWidget);
    });

    testWidgets('feed bisa difilter ke UKM yang diikuti', (tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapWithProviders(const MaterialApp(home: FeedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feed UKM'), findsOneWidget);
      expect(find.text('12 postingan'), findsOneWidget);

      await tester.tap(find.text('Diikuti'));
      await tester.pumpAndSettle();
      expect(find.text('2 postingan'), findsOneWidget);

      await tester.tap(find.text('Event').first);
      await tester.pumpAndSettle();
      expect(find.text('1 postingan'), findsOneWidget);
      expect(find.text('Workshop Flutter & Dart 2026'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('12 postingan'), findsOneWidget);
    });

    testWidgets('notifikasi menampilkan item dan aksi tandai semua', (
      tester,
    ) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapWithProviders(const MaterialApp(home: NotificationScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('1 notifikasi belum dibaca'), findsOneWidget);
      expect(
        find.text('Neo Telemetri memposting kabar baru'),
        findsNWidgets(2),
      );

      await tester.tap(find.byTooltip('Tandai semua dibaca'));
      await tester.pumpAndSettle();

      expect(find.textContaining('belum dibaca'), findsNothing);
    });

    testWidgets('detail postingan menampilkan isi dan lampiran', (
      tester,
    ) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapWithProviders(
          MaterialApp(
            theme: AppTheme.light,
            home: UkmPostDetailScreen(post: kDummyPostList.first),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail Postingan'), findsOneWidget);
      expect(find.text('Workshop Flutter & Dart 2026'), findsWidgets);
      expect(find.text('Lampiran'), findsOneWidget);
      expect(find.text('Panduan Workshop Flutter.pdf'), findsOneWidget);
      expect(find.text('Lihat Profil UKM'), findsOneWidget);
    });
  });
}
