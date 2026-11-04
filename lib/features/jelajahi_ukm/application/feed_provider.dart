import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/post.dart';
import '../data/post_dummy_data.dart';
import 'follow_provider.dart';

// ── Filter state providers ──────────────────────────────────────────────────

/// Search query for filtering posts by title or content.
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

/// Selected post category filter (null = all categories).
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? kategori) => state = kategori;
}

/// Selected UKM filter (null = all UKMs).
final selectedUkmFilterProvider =
    NotifierProvider<SelectedUkmFilterNotifier, String?>(
  SelectedUkmFilterNotifier.new,
);

class SelectedUkmFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? ukmId) => state = ukmId;
}

/// Whether to show only posts from followed UKMs (personal feed).
final personalFeedOnlyProvider =
    NotifierProvider<PersonalFeedOnlyNotifier, bool>(
  PersonalFeedOnlyNotifier.new,
);

class PersonalFeedOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

// ── Available categories ────────────────────────────────────────────────────

const List<String> kPostCategories = [
  'event',
  'lomba',
  'prestasi',
  'oprec',
  'pengumuman',
];

/// Human-readable label for each category.
String categoryLabel(String kategori) {
  switch (kategori) {
    case 'event':
      return 'Event';
    case 'lomba':
      return 'Lomba';
    case 'prestasi':
      return 'Prestasi';
    case 'oprec':
      return 'Open Recruitment';
    case 'pengumuman':
      return 'Pengumuman';
    default:
      return kategori;
  }
}

// ── Filtered post list ──────────────────────────────────────────────────────

/// Derives the filtered list of posts based on active filters (category, UKM, personal feed, search).
final filteredPostListProvider = Provider<List<Post>>((ref) {
  final searchQuery = ref.watch(postSearchQueryProvider).trim().toLowerCase();
  final kategori = ref.watch(selectedCategoryProvider);
  final ukmId = ref.watch(selectedUkmFilterProvider);
  final personalOnly = ref.watch(personalFeedOnlyProvider);
  final followedIds = ref.watch(followedUkmIdsProvider).value ?? {};

  var posts = List<Post>.from(kDummyPostList);

  // Search keyword filter
  if (searchQuery.isNotEmpty) {
    posts = posts.where((p) {
      final titleMatch = p.title.toLowerCase().contains(searchQuery);
      final contentMatch = p.content.toLowerCase().contains(searchQuery);
      final ukmMatch = p.ukmName.toLowerCase().contains(searchQuery);
      return titleMatch || contentMatch || ukmMatch;
    }).toList();
  }

  // Personal feed filter
  if (personalOnly) {
    posts = posts.where((p) => followedIds.contains(p.ukmId)).toList();
  }

  // Category filter
  if (kategori != null) {
    posts = posts.where((p) => p.kategori == kategori).toList();
  }

  // UKM filter
  if (ukmId != null) {
    posts = posts.where((p) => p.ukmId == ukmId).toList();
  }

  // Sort by date descending
  posts.sort((a, b) => b.tanggal.compareTo(a.tanggal));

  return posts;
});

/// Posts for a specific UKM (used in detail screen).
final postsByUkmProvider = Provider.family<List<Post>, String>((ref, ukmId) {
  return kDummyPostList
      .where((p) => p.ukmId == ukmId)
      .toList()
    ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
});