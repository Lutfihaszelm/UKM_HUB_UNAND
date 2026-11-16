import '../models/post.dart';
import 'post_dummy_data.dart';

/// Kontrak sumber data postingan Modul 1.
abstract class PostRepository {
  Future<List<Post>> fetchPosts({
    String? category,
    String? ukmId,
    String? query,
    int page = 1,
    int limit = 50,
  });

  Future<Post> fetchPostById(String id);
}

class FakePostRepository implements PostRepository {
  const FakePostRepository({this.delay = const Duration(milliseconds: 160)});

  final Duration delay;

  @override
  Future<List<Post>> fetchPosts({
    String? category,
    String? ukmId,
    String? query,
    int page = 1,
    int limit = 50,
  }) async {
    await Future<void>.delayed(delay);
    final normalized = query?.trim().toLowerCase() ?? '';
    final result = kDummyPostList.where((post) {
      if (category != null && post.category != category) return false;
      if (ukmId != null && post.author.id != ukmId) return false;
      if (normalized.isEmpty) return true;

      return post.title.toLowerCase().contains(normalized) ||
          post.description.toLowerCase().contains(normalized) ||
          (post.content?.toLowerCase().contains(normalized) ?? false) ||
          post.author.name.toLowerCase().contains(normalized) ||
          post.tags.any((tag) => tag.toLowerCase().contains(normalized));
    }).toList();

    result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return result;
  }

  @override
  Future<Post> fetchPostById(String id) async {
    await Future<void>.delayed(delay);
    return kDummyPostList.firstWhere(
      (post) => post.id == id,
      orElse: () => throw StateError('Postingan $id tidak ditemukan.'),
    );
  }
}
