/// Model data utama aplikasi.
/// Merepresentasikan satu postingan UKM pada feed (event, lomba,
/// prestasi, open recruitment, atau pengumuman).
class Post {
  final String id;
  final String title;
  final String subtitle;
  final String description;

  const Post({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
