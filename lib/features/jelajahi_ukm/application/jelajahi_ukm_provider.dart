import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../models/ukm.dart';
import 'repository_providers.dart';

/// Query pencarian UKM. Langsung diterapkan ke daftar (20 data, tanpa debounce
/// agar respons terasa instan; bisa ditambah debounce saat pindah ke API).
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

/// Daftar UKM dari repository (async, siap diganti API).
final ukmListProvider = FutureProvider<List<Ukm>>((ref) {
  final repository = ref.watch(ukmRepositoryProvider);
  return repository.fetchUkms();
});

/// Kategori yang dipilih dari tombol filter di bawah daftar UKM.
final ukmCategoryFilterProvider =
    NotifierProvider<UkmCategoryFilterNotifier, String?>(
      UkmCategoryFilterNotifier.new,
    );

class UkmCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String category) => state = category;

  void clear() => state = null;
}

/// Daftar kategori unik untuk pilihan filter.
final ukmCategoriesProvider = Provider<List<String>>((ref) {
  final items = ref.watch(ukmListProvider).value ?? const <Ukm>[];
  final categories =
      items.map((ukm) => ukm.category).whereType<String>().toSet().toList()
        ..sort();
  return categories;
});

/// Hasil pencarian + filter kategori di atas [ukmListProvider].
///
/// Tipe AsyncValue dipakai agar UI bisa membedakan loading, error, kosong,
/// dan data tanpa kehilangan hasil filter saat refresh.
final filteredUkmListProvider = Provider<AsyncValue<List<Ukm>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(ukmCategoryFilterProvider);
  final list = ref.watch(ukmListProvider);

  return list.whenData((items) {
    return items
        .where((ukm) {
          if (category != null && ukm.category != category) return false;
          if (query.isEmpty) return true;
          return ukm.name.toLowerCase().contains(query) ||
              ukm.description.toLowerCase().contains(query) ||
              (ukm.category?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
  });
});

/// Detail UKM. UI memakai data awal dari list sebagai fallback selama loading.
final ukmDetailProvider = FutureProvider.family<Ukm, String>((ref, id) {
  final repository = ref.watch(ukmRepositoryProvider);
  return repository.fetchUkmById(id);
});

/// Postingan milik satu UKM untuk tab "Postingan" di halaman detail.
final ukmPostsProvider = FutureProvider.family<List<Post>, String>((ref, id) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPosts(ukmId: id);
});

/// Jumlah UKM yang ditampilkan pada badge "20 UKM".
final filteredUkmCountProvider = Provider<int>((ref) {
  return ref.watch(filteredUkmListProvider).value?.length ?? 0;
});
