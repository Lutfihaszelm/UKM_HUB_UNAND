/// Model postingan untuk Modul 1 (feed & detail postingan).
///
/// Bentuknya mengikuti objek Post di `docs/api-contract.md`:
/// id, category, badge, ukm, title, description, location, tags, banner_url,
/// like_count, comment_count, liked_by_me, published_at. Detail postingan
/// menambah content dan attachments.
class Post {
  const Post({
    required this.id,
    required this.category,
    required this.author,
    required this.title,
    required this.description,
    required this.publishedAt,
    this.badge,
    this.location,
    this.tags = const [],
    this.bannerUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
    this.content,
    this.attachments = const [],
  });

  final String id;

  /// Salah satu dari: event, lomba, prestasi, oprec, pengumuman.
  final String category;

  /// Label singkat dari server, mis. "Event Nasional".
  final String? badge;

  /// UKM penulis postingan (bentuk ringkas objek UKM).
  final PostAuthor author;

  final String title;
  final String description;
  final String? location;
  final List<String> tags;
  final String? bannerUrl;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final DateTime publishedAt;

  /// Isi lengkap; hanya tersedia dari endpoint detail.
  final String? content;

  /// Lampiran; hanya tersedia dari endpoint detail.
  final List<PostAttachment> attachments;

  String get categoryLabel {
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

  String get readableContent {
    final text = content?.trim();
    if (text != null && text.isNotEmpty) return text;
    return description;
  }

  Post copyWith({
    String? id,
    String? category,
    String? badge,
    PostAuthor? author,
    String? title,
    String? description,
    String? location,
    List<String>? tags,
    String? bannerUrl,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    DateTime? publishedAt,
    String? content,
    List<PostAttachment>? attachments,
  }) {
    return Post(
      id: id ?? this.id,
      category: category ?? this.category,
      badge: badge ?? this.badge,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawUkm = json['ukm'];
    final ukmJson = rawUkm is Map<String, dynamic>
        ? rawUkm
        : const <String, dynamic>{};
    final rawAttachments = json['attachments'];

    return Post(
      id: (json['id'] ?? '').toString(),
      category: (json['category'] ?? 'pengumuman').toString(),
      badge: json['badge'] as String?,
      author: PostAuthor.fromJson(ukmJson),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: json['location'] as String?,
      tags: _stringList(json['tags']),
      bannerUrl: json['banner_url'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      publishedAt:
          DateTime.tryParse((json['published_at'] ?? '').toString())
              ?.toLocal() ??
          DateTime.now(),
      content: json['content'] as String?,
      attachments: rawAttachments is List
          ? rawAttachments
                .whereType<Map>()
                .map(
                  (item) =>
                      PostAttachment.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'badge': badge,
      'ukm': author.toJson(),
      'title': title,
      'description': description,
      'location': location,
      'tags': tags,
      'banner_url': bannerUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
      'liked_by_me': likedByMe,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'content': content,
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'oprec': null,
    };
  }
}

/// Bentuk ringkas UKM yang menempel pada objek Post.
class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final bool isVerified;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      logoUrl: json['logo_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'is_verified': isVerified,
    };
  }
}

/// Lampiran postingan (gambar, video, atau dokumen).
class PostAttachment {
  const PostAttachment({
    required this.id,
    required this.type,
    required this.name,
    this.sizeBytes = 0,
    this.url,
  });

  final String id;

  /// image, video, atau document.
  final String type;
  final String name;
  final int sizeBytes;
  final String? url;

  factory PostAttachment.fromJson(Map<String, dynamic> json) {
    return PostAttachment(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'document').toString(),
      name: (json['name'] ?? '').toString(),
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'size_bytes': sizeBytes,
      'url': url,
    };
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}
