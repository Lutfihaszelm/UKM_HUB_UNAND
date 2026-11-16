import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import 'follow_provider.dart';
import 'repository_providers.dart';

/// Cakupan feed: semua UKM atau hanya UKM yang diikuti.
enum FeedScope {
  all('Semua'),
  following('Diikuti');

  const FeedScope(this.label);

  final String label;
}

/// Lima kategori postingan sesuai kontrak API.
const List<String> kFeedCategories = [
  'event',
  'lomba',
  'prestasi',
  'oprec',
  'pengumuman',
];

String feedCategoryLabel(String category) {
  switch (category) {
    case 'event':
      return 'Event';
    case 'lomba':
      return 'Lomba';
    case 'prestasi':
      return 'Prestasi';
    case 'oprec':
      return 'Oprec';
    case 'pengumuman':
      return 'Pengumuman';
    default:
      return category;
  }
}

// ── Filter state ────────────────────────────────────────────────────────────

final feedScopeProvider = NotifierProvider<FeedScopeNotifier, FeedScope>(
  FeedScopeNotifier.new,
);

class FeedScopeNotifier extends Notifier<FeedScope> {
  @override
  FeedScope build() => FeedScope.all;

  void select(FeedScope scope) => state = scope;
}

final postSearchQueryProvider =
    NotifierProvider<PostSearchQueryNotifier, String>(
      PostSearchQueryNotifier.new,
    );

class PostSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

/// null = semua kategori.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
  void clear() => state = null;
}

/// null = semua UKM.
final selectedFeedUkmProvider =
    NotifierProvider<SelectedFeedUkmNotifier, String?>(
      SelectedFeedUkmNotifier.new,
    );

class SelectedFeedUkmNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? ukmId) => state = ukmId;
  void clear() => state = null;
}

final hasActiveFeedFilterProvider = Provider<bool>((ref) {
  return ref.watch(feedScopeProvider) != FeedScope.all ||
      ref.watch(selectedCategoryProvider) != null ||
      ref.watch(selectedFeedUkmProvider) != null ||
      ref.watch(postSearchQueryProvider).trim().isNotEmpty;
});

// ── Data ────────────────────────────────────────────────────────────────────

/// Semua postingan tanpa filter. Dipakai juga oleh notifikasi untuk memetakan
/// post_id ke UKM pemiliknya.
final allPostsProvider = FutureProvider<List<Post>>((ref) {
  return ref.watch(postRepositoryProvider).fetchPosts();
});

/// Feed sesuai scope + kategori + UKM + kata kunci.
///
/// `scope=following` disaring di sisi klien untuk implementasi dummy. Saat
/// API siap, parameter scope bisa diteruskan langsung ke `GET /posts`.
final feedPostsProvider = FutureProvider<List<Post>>((ref) async {
  final scope = ref.watch(feedScopeProvider);
  final category = ref.watch(selectedCategoryProvider);
  final ukmId = ref.watch(selectedFeedUkmProvider);
  final query = ref.watch(postSearchQueryProvider);

  final posts = await ref
      .watch(postRepositoryProvider)
      .fetchPosts(category: category, ukmId: ukmId, query: query);

  if (scope == FeedScope.all) return posts;

  final followed = await ref.watch(followedUkmIdsProvider.future);
  return posts
      .where((post) => followed.contains(post.author.id))
      .toList(growable: false);
});

final postByIdProvider = FutureProvider.family<Post, String>((ref, id) {
  return ref.watch(postRepositoryProvider).fetchPostById(id);
});
