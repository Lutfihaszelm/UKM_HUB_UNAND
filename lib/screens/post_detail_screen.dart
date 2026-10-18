import 'package:flutter/material.dart';
import '../models/campus_post.dart';
import '../services/storage_service.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Postingan aktif (jika diteruskan dari navigasi)
  CampusPost? _post;
  bool _initialized = false;

  // ID unik postingan — dipakai sebagai key di StorageService
  String get _postId => _post?.id ?? 'post-pkm-2026';

  bool _isFollowing = false;
  bool _isLiked = false;
  int _likeCount = 127;
  bool _isBookmarked = false;

  // Filter komentar: 'popular' (Terpopuler) atau 'newest' (Terbaru)
  String _commentFilter = 'popular';

  // Foto postingan
  String? _postImageUrl;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  // State balasan
  String? _replyingToName;
  String? _replyingToCommentId;

  // Set ID komentar yang sedang dalam animasi memudar (fade out)
  final Set<String> _fadingCommentIds = {};

  // ─── StorageService shortcut ─────────────────────────────────────────────
  final _storage = StorageService.instance;

  String _getCurrentUserName() {
    final email = _storage.email.trim();
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    } else if (email.isNotEmpty) {
      return email;
    }
    final username = _storage.username.trim();
    if (username.isNotEmpty && username != 'Pengguna') {
      return username;
    }
    return 'farrel';
  }

  String _getCurrentUserInitial() {
    final name = _getCurrentUserName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  final List<Map<String, dynamic>> _comments = [
    {
      'id': 'c-3',
      'name': 'Aldo dikala hujan`',
      'dept': '(Farmasi)',
      'initial': 'SN',
      'isMe': false,
      'isOrganizer': false,
      'time': '15 menit lalu',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch,
      'content':
          'Bismillah otw cari partner tim lintas fakultas, info anak IT yang mau join riset smart health yaa! 🙋‍♀️',
      'likes': 5,
      'isLikedByMe': false,
      'replyToName': null,
      'replyToId': null,
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CampusPost) {
        _post = args;
        _likeCount = args.initialLikes;
      }
      _loadPersistedData();
    }
  }

  // Muat data yang sudah tersimpan dari storage (komentar, like postingan)
  void _loadPersistedData() {
    // Like postingan
    final liked = _storage.isPostLiked(_postId);
    final count = _storage.getPostLikeCount(_postId, defaultCount: _post?.initialLikes ?? _likeCount);

    // Komentar
    final savedComments = _storage.loadComments(_postId);
    // Like komentar
    final likeMap = _storage.loadCommentLikeCounts(_postId);
    final likedByMe = _storage.loadCommentLikedByMe(_postId);

    setState(() {
      _isLiked = liked;
      _likeCount = count;

      _comments.clear();
      if (savedComments != null && savedComments.isNotEmpty) {
        _comments.addAll(savedComments);
      } else {
        _comments.addAll(_getInitialComments(_postId));
      }

      // Terapkan like komentar yang sudah tersimpan
      for (final c in _comments) {
        final id = c['id'] as String;
        if (likeMap.containsKey(id)) c['likes'] = likeMap[id];
        c['isLikedByMe'] = likedByMe.contains(id);
      }
    });
  }

  List<Map<String, dynamic>> _getInitialComments(String postId) {
    if (postId == 'post-neo-firetech') {
      return [
        {
          'id': 'c-neo-1',
          'name': 'Aldo Pratama',
          'dept': '(Sistem Informasi)',
          'initial': 'AP',
          'isMe': false,
          'isOrganizer': false,
          'time': '1 jam lalu',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
          'content':
              'Kategori Hackathon web & mobile development boleh tim kolaborasi lintas prodi dan fakultas gak min?',
          'likes': 12,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
        {
          'id': 'c-neo-2',
          'name': 'UKM Neo Telemetri',
          'dept': '',
          'initial': 'NT',
          'isMe': false,
          'isOrganizer': true,
          'time': '40 menit lalu',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 40)).millisecondsSinceEpoch,
          'content':
              '@Aldo Pratama Tentu boleh banget! Sangat direkomendasikan kolaborasi multidisiplin antara programmer, designer, dan ide bisnis 🔥',
          'likes': 19,
          'isLikedByMe': false,
          'replyToName': 'Aldo Pratama',
          'replyToId': 'c-neo-1',
        },
        {
          'id': 'c-neo-3',
          'name': 'Fikri Alamsyah',
          'dept': '(Teknik Sipil)',
          'initial': 'FA',
          'isMe': true,
          'isOrganizer': false,
          'time': '20 menit lalu',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 20)).millisecondsSinceEpoch,
          'content':
              'Info temen yang mau buat aplikasi smart campus untuk firetech yuk, saya handle UI/UX nya! 🚀',
          'likes': 5,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
      ];
    } else if (postId == 'post-aiesec-kalimantan') {
      return [
        {
          'id': 'c-aie-1',
          'name': 'Dinda Larasati',
          'dept': '(Biologi)',
          'initial': 'DL',
          'isMe': false,
          'isOrganizer': false,
          'time': '3 jam lalu',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
          'content':
              'Kegiatan reboisasinya di daerah mana Kalimantan Timur min? Dan apakah ada seleksi wawancara?',
          'likes': 8,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
        {
          'id': 'c-aie-2',
          'name': 'AIESEC in Unand',
          'dept': '',
          'initial': 'AI',
          'isMe': false,
          'isOrganizer': true,
          'time': '2 jam lalu',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          'content':
              '@Dinda Larasati Lokasi utama di kawasan konservasi Samboja & pesisir Balikpapan yaa. Seleksi berkas dan interview santai via daring 🌱',
          'likes': 15,
          'isLikedByMe': false,
          'replyToName': 'Dinda Larasati',
          'replyToId': 'c-aie-1',
        },
      ];
    } else if (postId == 'post-bem-dialog') {
      return [
        {
          'id': 'c-bem-1',
          'name': 'Rian Hidayat',
          'dept': '(Fakultas Hukum)',
          'initial': 'RH',
          'isMe': false,
          'isOrganizer': false,
          'time': '2 jam lalu',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          'content':
              'Siap hadir merapatkan barisan! Tuntaskan kajian evaluasi menteri bermasalah dan kawal komitmen pendidikan gratis di kampus! ✊',
          'likes': 45,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
        {
          'id': 'c-bem-2',
          'name': 'BEM KM UNAND',
          'dept': '',
          'initial': 'BM',
          'isMe': false,
          'isOrganizer': true,
          'time': '1 jam lalu',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
          'content':
              '@Rian Hidayat Sepakat! Seluruh draf kajian naskah akademik akan dibagikan terbuka di mimbar bebas. Sampai jumpa di pelataran PKM! 🇮🇩📢',
          'likes': 38,
          'isLikedByMe': false,
          'replyToName': 'Rian Hidayat',
          'replyToId': 'c-bem-1',
        },
      ];
    } else {
      return [
        {
          'id': 'c-3',
          'name': 'Aldo dikala hujan`',
          'dept': '(Farmasi)',
          'initial': 'SN',
          'isMe': false,
          'isOrganizer': false,
          'time': '15 menit lalu',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch,
          'content':
              'Bismillah otw cari partner tim lintas fakultas, info anak IT yang mau join riset smart health yaa! 🙋‍♀️',
          'likes': 5,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
      ];
    }
  }

  // Simpan komentar ke storage setelah setiap perubahan
  Future<void> _persistComments() async {
    await _storage.saveComments(_postId, _comments);
    // Simpan juga state like komentar
    final likeMap = {for (final c in _comments) c['id'] as String: c['likes'] as int};
    final likedByMe = _comments
        .where((c) => c['isLikedByMe'] == true)
        .map((c) => c['id'] as String)
        .toSet();
    await _storage.saveCommentLikes(_postId, likeMap: likeMap, likedByMeIds: likedByMe);
  }

  // Toggle like postingan + simpan ke storage
  void _togglePostLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
    // Simpan ke storage agar like postingan tidak hilang
    _storage.togglePostLike(_postId, currentCount: _likeCount);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // GETTER KOMENTAR DENGAN FILTER (Terpopuler & Terbaru)
  // Komentar utama difilter/diurutkan, balasan hanya mengikuti komentar utama
  // ===========================================================================
  List<Map<String, dynamic>> get _filteredComments {
    // 1. Buat map id -> komentar untuk melacak komentar induk (root)
    final Map<String, Map<String, dynamic>> commentMap = {
      for (final c in _comments) c['id'] as String: c,
    };

    // Fungsi pencari ID komentar utama (paling atas dalam thread balasan)
    String getRootCommentId(String startId) {
      String curr = startId;
      final visited = <String>{};
      while (visited.add(curr)) {
        final c = commentMap[curr];
        if (c == null) return curr;
        final parentId = c['replyToId'] as String?;
        if (parentId == null || !commentMap.containsKey(parentId)) {
          return curr;
        }
        curr = parentId;
      }
      return curr;
    }

    // 2. Pisahkan komentar utama dan kumpulkan komentar balasan per root ID
    final List<Map<String, dynamic>> mainComments = [];
    final Map<String, List<Map<String, dynamic>>> repliesByRootId = {};

    for (final c in _comments) {
      final replyToId = c['replyToId'] as String?;
      if (replyToId == null || !commentMap.containsKey(replyToId)) {
        // Ini adalah komentar utama
        mainComments.add(c);
      } else {
        // Ini adalah komentar balasan, kaitkan ke komentar utama teratas
        final rootId = getRootCommentId(replyToId);
        repliesByRootId.putIfAbsent(rootId, () => []).add(c);
      }
    }

    // 3. Urutkan HANYA komentar utama berdasarkan filter yang dipilih
    if (_commentFilter == 'popular') {
      // Terpopuler: Urutkan komentar utama dari like terbanyak
      mainComments.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
    } else {
      // Terbaru: Urutkan komentar utama dari waktu terbaru (timestamp terbesar)
      mainComments.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    }

    // 4. Susun daftar akhir: Setiap komentar utama diikuti langsung oleh balasannya
    final List<Map<String, dynamic>> result = [];
    for (final mainComment in mainComments) {
      result.add(mainComment);
      final replies = repliesByRootId[mainComment['id']];
      if (replies != null && replies.isNotEmpty) {
        // Balasan diurutkan secara kronologis (dari balasan awal ke balasan terakhir)
        replies.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
        result.addAll(replies);
      }
    }

    return result;
  }

  // ===========================================================================
  // FUNGSI LIKE KOMENTAR (Instagram Style)
  // ===========================================================================
  void _toggleCommentLike(Map<String, dynamic> comment) {
    setState(() {
      final isLiked = comment['isLikedByMe'] == true;
      if (isLiked) {
        comment['isLikedByMe'] = false;
        comment['likes'] = (comment['likes'] as int) - 1;
      } else {
        comment['isLikedByMe'] = true;
        comment['likes'] = (comment['likes'] as int) + 1;
      }
    });
    // Simpan ke storage agar like tidak hilang saat app ditutup
    _persistComments();
  }

  // ===========================================================================
  // POP-UP SHARE KE APLIKASI (WhatsApp, Instagram, Facebook, TikTok, dll.)
  // ===========================================================================
  void _showShareModal() {
    final shareApps = [
      {
        'name': 'WhatsApp',
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF25D366),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'name': 'Instagram',
        'icon': Icons.camera_alt_outlined,
        'color': const Color(0xFFE1306C),
        'bg': const Color(0xFFFCE4EC),
      },
      {
        'name': 'Facebook',
        'icon': Icons.facebook,
        'color': const Color(0xFF1877F2),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'name': 'TikTok',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFF000000),
        'bg': const Color(0xFFF1F5F9),
      },
      {
        'name': 'Salin Tautan',
        'icon': Icons.link_rounded,
        'color': const Color(0xFF2C6E49),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'name': 'Lainnya...',
        'icon': Icons.more_horiz_rounded,
        'color': const Color(0xFF64748B),
        'bg': const Color(0xFFF1F5F9),
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bagikan Postingan Ini',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih media sosial atau aplikasi tujuan:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: shareApps.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, idx) {
                    final app = shareApps[idx];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSuccessDialog('Postingan berhasil dibagikan ke ${app['name']}!');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: app['bg'] as Color,
                              child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              app['name'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // FITUR LAPOR KOMENTAR (Alur: Klik Bendera -> Pop-up Alasan -> Pop-up Sukses)
  // ===========================================================================
  void _reportComment(Map<String, dynamic> comment) {
    final reasons = [
      {'title': 'Kata Kasar & Ujaran Kebencian', 'desc': 'Komentar mengandung hinaan, SARA, atau bahasa kasar.'},
      {'title': 'Konten Seksual & Pornografi', 'desc': 'Mengandung unsur seksual vulgar atau tidak senonoh.'},
      {'title': 'Kekerasan & Ancaman Bahaya', 'desc': 'Menyuarakan atau memicu tindakan kekerasan dan ancaman.'},
      {'title': 'Spam atau Penipuan', 'desc': 'Iklan mencurigakan, phishing, atau spam pengulangan.'},
      {'title': 'Informasi Palsu (Hoaks)', 'desc': 'Menyebarkan informasi yang salah seputar kegiatan/kampus.'},
    ];

    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: Color(0xFFDC2626), size: 24),
                SizedBox(width: 8),
                Text(
                  'Laporkan Komentar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Mengapa Anda melaporkan komentar ini?',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.normal),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: reasons.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final r = reasons[i];
              return InkWell(
                onTap: () => Navigator.pop(ctx, r['title']),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title']!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r['desc']!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    ).then((selectedReason) {
      if (selectedReason != null && mounted) {
        _showSuccessDialog('Laporan telah berhasil dikirim! Tim moderator akan segera meninjau komentar ini.');
      }
    });
  }

  // Pop-up Notifikasi Sukses
  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2C6E49), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Berhasil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FUNGSI BALAS KOMENTAR
  // ===========================================================================
  void _startReply(Map<String, dynamic> targetComment) {
    setState(() {
      _replyingToName = targetComment['name'] as String;
      _replyingToCommentId = targetComment['id'] as String;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToName = null;
      _replyingToCommentId = null;
    });
  }

  // ===========================================================================
  // FUNGSI KIRIM KOMENTAR / BALASAN
  // ===========================================================================
  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Validasi minimal 3 karakter
    if (text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Komentar minimal 3 karakter',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final myName = _getCurrentUserName();
    final myInitial = _getCurrentUserInitial();

    final newComment = {
      'id': 'c-${DateTime.now().millisecondsSinceEpoch}',
      'name': myName,
      'dept': '',
      'initial': myInitial,
      'isMe': true,
      'isOrganizer': false,
      'time': 'Baru saja',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': text,
      'likes': 0,
      'isLikedByMe': false,
      'replyToName': _replyingToName,
      'replyToId': _replyingToCommentId,
    };

    setState(() {
      if (_replyingToCommentId != null) {
        int parentIndex = _comments.indexWhere((c) => c['id'] == _replyingToCommentId);
        if (parentIndex != -1) {
          int insertIndex = parentIndex + 1;
          while (insertIndex < _comments.length &&
              _comments[insertIndex]['replyToId'] == _replyingToCommentId) {
            insertIndex++;
          }
          _comments.insert(insertIndex, newComment);
        } else {
          _comments.add(newComment);
        }
      } else {
        _comments.add(newComment);
      }

      _commentController.clear();
      _replyingToName = null;
      _replyingToCommentId = null;
    });
    // Simpan komentar baru ke storage
    _persistComments();
  }

  // ===========================================================================
  // FUNGSI EDIT KOMENTAR SENDIRI
  // ===========================================================================
  void _editComment(Map<String, dynamic> comment) {
    final editController = TextEditingController(text: comment['content'] as String);

    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Komentar',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: Color(0xFF141B2B)),
          decoration: InputDecoration(
            hintText: 'tulis isi komentar',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C6E49), width: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(ctx, newText);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C6E49),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).then((updatedText) {
      if (updatedText != null && updatedText.isNotEmpty && mounted) {
        setState(() {
          comment['content'] = updatedText;
          comment['time'] = 'Diedit baru saja';
        });
        // Simpan hasil edit ke storage
        _persistComments();
      }
    });
  }

  // ===========================================================================
  // FUNGSI HAPUS KOMENTAR (Fade-out, Konfirmasi, Tanpa Snackbar)
  // ===========================================================================
  void _deleteCommentWithFade(Map<String, dynamic> comment) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Komentar?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Komentar ini akan dihapus secara permanen dari postingan.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        final commentId = comment['id'] as String;

        setState(() {
          _fadingCommentIds.add(commentId);
        });

        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              _comments.removeWhere((c) => c['id'] == commentId);
              _fadingCommentIds.remove(commentId);
            });
            // Simpan setelah komentar terhapus
            _persistComments();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2C6E49);
    final displayedComments = _filteredComments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF141B2B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post Detail',
          style: TextStyle(
            color: Color(0xFF141B2B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? primaryColor : const Color(0xFF404942),
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          // Tombol share di AppBar membuka dialog pop-up share
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF404942)),
            onPressed: _showShareModal,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Header Profil UKM
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _post?.iconBgColor ?? const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          _post?.icon ?? Icons.psychology,
                          color: _post?.iconColor ?? primaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _post?.authorName ?? 'UKM Penalaran & Riset',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF141B2B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_post?.isVerified ?? true) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: _post?.iconColor ?? primaryColor,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _post?.authorSubtitle ?? '2 jam yang lalu • Kampus Limau Manis',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF707971),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isFollowing ? primaryColor : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFollowing ? Icons.check : Icons.add,
                              size: 16,
                              color: _isFollowing ? Colors.white : primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFollowing ? 'Mengikuti' : 'Ikuti',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isFollowing ? Colors.white : primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Poster Banner / Foto Postingan
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      _postImageUrl != null
                          ? Image.network(
                              _postImageUrl!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultGraphicBanner(primaryColor);
                              },
                            )
                          : (_post?.assetImagePath != null
                              ? Image.asset(
                                  _post!.assetImagePath!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultGraphicBanner(primaryColor);
                                  },
                                )
                              : _buildDefaultGraphicBanner(primaryColor)),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_post?.iconColor ?? primaryColor).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: Color(0xFFAEF2C5), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _post?.categoryBadge ?? 'Event Nasional',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Terbuka Umum',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Judul & Deskripsi
                Text(
                  _post?.title ??
                      'Analisi Reaksi Normies ketika melihat balasan instragam  dengan gif meme "WHAT NEXT" terhadap kehidupan bersosial media',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF141B2B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _post?.fullContent ??
                      'Halo Mahasiswa Unand! UKM Penalaran resmi membuka pendaftaran pembinaan intensif Program Kreativitas Mahasiswa (PKM) & Call for Papers tingkat nasional. Dapatkan bimbingan intensif dari dosen pembina serta fasilitas pendanaan riset kampus. Kuota terbatas untuk seluruh fakultas! ✨📚',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF404942),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Hashtags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (_post?.tags ?? [
                    '#UKMPenalaran',
                    '#PKMUnand',
                    '#PrestasiKampus',
                    '#RisetMahasiswa',
                  ]).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: _post?.iconColor ?? primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Action Bar (Like, Comment, Share)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Like Button
                      InkWell(
                        onTap: _togglePostLike,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isLiked ? const Color(0xFFDCFCE7) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: _isLiked ? primaryColor : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_likeCount Suka',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _isLiked ? primaryColor : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.mode_comment_outlined, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            '${_comments.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Tombol Share membuka pop-up pilihan media sosial
                      InkWell(
                        onTap: _showShareModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: const [
                              Icon(Icons.share_outlined, size: 18, color: Color(0xFF64748B)),
                              SizedBox(width: 4),
                              Text(
                                'Bagikan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Komentar Header & Filter Dropdown (Terpopuler / Terbaru)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF141B2B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_comments.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Dropdown Filter Komentar Terpopuler / Terbaru
                    PopupMenuButton<String>(
                      initialValue: _commentFilter,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        setState(() {
                          _commentFilter = val;
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'popular',
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 18,
                                color: _commentFilter == 'popular' ? primaryColor : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Terpopuler',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _commentFilter == 'popular' ? FontWeight.w700 : FontWeight.normal,
                                  color: _commentFilter == 'popular' ? primaryColor : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'newest',
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: _commentFilter == 'newest' ? primaryColor : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Terbaru',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _commentFilter == 'newest' ? FontWeight.w700 : FontWeight.normal,
                                  color: _commentFilter == 'newest' ? primaryColor : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _commentFilter == 'popular' ? 'Terpopuler' : 'Terbaru',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Daftar Komentar (Sesuai Filter)
                for (final comment in displayedComments) ...[
                  _buildAnimatedCommentItem(comment, primaryColor),
                ],
              ],
            ),
          ),

          // Bar Input Komentar Bawah dengan Indikator Balas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Banner kecil saat sedang membalas komentar orang
                  if (_replyingToName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(left: BorderSide(color: primaryColor, width: 3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.reply_rounded, size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Membalas $_replyingToName',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _cancelReply,
                            child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: _replyingToName != null
                                  ? 'Tulis balasan untuk $_replyingToName...'
                                  : 'Tulis tanggapan atau pertanyaan...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _sendComment,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Banner grafis default jika tidak ada file foto
  Widget _buildDefaultGraphicBanner(Color primaryColor) {
    final gradient = _post?.bannerGradient ?? const [Color(0xFF004528), Color(0xFF1B6D24)];
    final icon = _post?.bannerIcon ?? Icons.workspace_premium;
    final title = _post?.bannerTitle ?? 'NATIONAL STUDENT SCIENTIFIC\nPAPER COMPETITION 2026';
    final subtitle = _post?.bannerSubtitle ?? 'SEMINAR & WORKSHOP INTENSIF PKM';

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: gradient.first,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 160,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: const Color(0xFFFACC15)),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF93D5AA),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Item Komentar dengan Like Heart ala Instagram & Tombol Bendera Lapor
  Widget _buildAnimatedCommentItem(Map<String, dynamic> c, Color primaryColor) {
    final commentId = c['id'] as String;
    final isFading = _fadingCommentIds.contains(commentId);
    final isOrganizer = c['isOrganizer'] == true;
    final isMe = c['isMe'] == true;
    final isReply = c['replyToId'] != null;
    final isLikedByMe = c['isLikedByMe'] == true;
    final likesCount = c['likes'] as int;
    final displayName = isMe ? _getCurrentUserName() : (c['name'] as String);
    final displayInitial = isMe ? _getCurrentUserInitial() : (c['initial'] as String? ?? 'U');

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isFading ? 0.0 : 1.0,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 14,
          left: isReply ? 24 : (isOrganizer ? 20 : 0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 16 : 18,
              backgroundColor: isOrganizer
                  ? primaryColor
                  : (isMe ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0)),
              child: isOrganizer
                  ? Icon(_post?.icon ?? Icons.psychology, size: 18, color: Colors.white)
                  : Text(
                      displayInitial,
                      style: TextStyle(
                        fontSize: isReply ? 11 : 12,
                        fontWeight: FontWeight.bold,
                        color: isMe ? const Color(0xFF2C6E49) : const Color(0xFF1E293B),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOrganizer ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOrganizer ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header: nama + badge (Anda / Penyelenggara) ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Nama akun
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            // Badge hijau "Anda"
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C6E49),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Anda',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            // Badge "Penyelenggara"
                            if (isOrganizer) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B6D24),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Penyelenggara',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (c['replyToName'] != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Membalas @${c['replyToName']}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          c['content'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bar Bawah Komentar (Waktu · Balas · Edit · Hapus · Flag) ──
                  // Tombol bendera & titik-tiga dipindah ke sini agar tidak
                  // berdesakan dengan nama di header (fix overflow).
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Row(
                      children: [
                        Text(
                          c['time'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 10),
                        // Tombol Balas
                        InkWell(
                          onTap: () => _startReply(c),
                          child: Text(
                            'Balas',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 10),
                          // Edit
                          InkWell(
                            onTap: () => _editComment(c),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2C6E49),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Hapus
                          InkWell(
                            onTap: () => _deleteCommentWithFade(c),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Titik tiga (Edit/Hapus via menu)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, size: 15, color: Color(0xFF94A3B8)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onSelected: (value) {
                              if (value == 'edit') _editComment(c);
                              if (value == 'delete') _deleteCommentWithFade(c);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                height: 36,
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 15, color: Color(0xFF334155)),
                                  SizedBox(width: 8),
                                  Text('Edit', style: TextStyle(fontSize: 13)),
                                ]),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                height: 36,
                                child: Row(children: [
                                  Icon(Icons.delete_outline, size: 15, color: Color(0xFFDC2626)),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(width: 6),
                          // Bendera laporan untuk komentar orang lain
                          InkWell(
                            onTap: () => _reportComment(c),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.outlined_flag, size: 14, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // LIKE LOVE ALA INSTAGRAM (Pojok Kanan Luar Bubble)
            // =================================================================
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _toggleCommentLike(c),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isLikedByMe ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  if (likesCount > 0)
                    Text(
                      '$likesCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isLikedByMe ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
