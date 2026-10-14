import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ukm.dart';
import '../data/ukm_dummy_data.dart';

/// Holds the current search query entered by the user.
/// Uses Notifier (Riverpod 3.x) instead of the removed StateProvider.
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

/// Derives the filtered UKM list from [kDummyUkmList] based on the
/// current search query. Case-insensitive, trims whitespace.
final filteredUkmListProvider = Provider<List<Ukm>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) {
    return kDummyUkmList;
  }

  return kDummyUkmList
      .where((ukm) => ukm.name.toLowerCase().contains(query))
      .toList();
});
