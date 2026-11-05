/// Model for a UKM post/announcement.
class Post {
  const Post({
    required this.id,
    required this.ukmId,
    required this.ukmName,
    required this.title,
    required this.content,
    required this.kategori,
    required this.tanggal,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
  });

  final String id;

  /// Foreign key to [Ukm.id].
  final String ukmId;

  /// Denormalized UKM name for display convenience.
  final String ukmName;

  final String title;
  final String content;

  /// Post category: 'event', 'lomba', 'prestasi', 'oprec', 'pengumuman'.
  final String kategori;

  /// Publication date.
  final DateTime tanggal;

  /// Optional image URL / asset path.
  final String? imageUrl;

  /// Number of likes on this post.
  final int likes;

  /// Number of comments on this post.
  final int comments;
}
