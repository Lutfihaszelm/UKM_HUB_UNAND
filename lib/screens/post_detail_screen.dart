import 'package:flutter/material.dart';
import '../core/routing/app_routes.dart';
import '../models/campus_post.dart';
import '../services/storage_service.dart';
import '../widgets/profile_avatar.dart';

/// Halaman Detail Postingan (Post Detail Screen) untuk aplikasi "UKM Hub Unand".
///
/// Fitur Utama:
/// - Foto postingan proporsional seperti di beranda (tidak terpotong / tidak ter-zoom in/out secara paksa).
/// - Ketika foto ditekan, membuka penampil interaktif layar penuh dengan fitur pinch-to-zoom (zoom in & out pakai jari).
/// - Lembar putih (DraggableScrollableSheet) meluncur dari bawah dengan garis handle ("garis kecil").
/// - Menekan atau menggeser garis kecil ke bawah akan memuat foto secara penuh (full).
/// - Mengklik ikon komentar di kartu statistik secara otomatis menggeser lembar ke bawah menuju bagian komentar.
/// - Bebas overflow ("bottom overflowed by 35 pixels" fixed).
/// - Sistem komentar lengkap tersimpan di StorageService.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Postingan aktif
  CampusPost? _post;
  bool _initialized = false;

  // ID unik postingan
  String get _postId => _post?.id ?? 'post-rezim-gibran';

  bool _isLiked = false;
  int _likeCount = 1067;

  // Filter komentar: 'popular' (Terpopuler) atau 'newest' (Terbaru)
  String _commentFilter = 'popular';

  // Foto postingan (jika URL network)
  String? _postImageUrl;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  // Controller untuk lembar geser konten (DraggableScrollableSheet)
  late final DraggableScrollableController _sheetController;

  // ScrollController yang aktif dari DraggableScrollableSheet
  ScrollController? _activeScrollController;

  // State balasan komentar
  String? _replyingToName;
  String? _replyingToCommentId;

  // Set ID komentar yang sedang dalam animasi memudar (fade out)
  final Set<String> _fadingCommentIds = {};

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

  String get _currentDisplayTitleName {
    final name = _getCurrentUserName();
    if (name.isEmpty) return 'You';
    return name[0].toUpperCase() + name.substring(1);
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
      'likes': 6,
      'isLikedByMe': false,
      'replyToName': null,
      'replyToId': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
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

  void _loadPersistedData() {
    final liked = _storage.isPostLiked(_postId);
    final count = _storage.getPostLikeCount(_postId, defaultCount: _post?.initialLikes ?? _likeCount);
    final savedComments = _storage.loadComments(_postId);
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
          'likes': 6,
          'isLikedByMe': false,
          'replyToName': null,
          'replyToId': null,
        },
      ];
    }
  }

  Future<void> _persistComments() async {
    await _storage.saveComments(_postId, _comments);
    final likeMap = {for (final c in _comments) c['id'] as String: c['likes'] as int};
    final likedByMe = _comments
        .where((c) => c['isLikedByMe'] == true)
        .map((c) => c['id'] as String)
        .toSet();
    await _storage.saveCommentLikes(_postId, likeMap: likeMap, likedByMeIds: likedByMe);
  }

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
    _storage.togglePostLike(_postId, currentCount: _likeCount);
  }

  void _toggleSheetExpand() {
    if (!_sheetController.isAttached) return;
    final current = _sheetController.size;
    final target = current > 0.25 ? 0.10 : 0.65;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Menggeser otomatis ke bagian komentar saat klik logo komentar ──────────
  void _scrollToComments() {
    // 1. Naikkan lembar hingga 0.95 agar bagian komentar leluasa dilihat
    if (_sheetController.isAttached && _sheetController.size < 0.85) {
      _sheetController.animateTo(
        0.95,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    // 2. Scroll konten ListView secara mulus ke bawah (posisi komentar)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_activeScrollController != null && _activeScrollController!.hasClients) {
        _activeScrollController!.animateTo(
          240.0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
      _commentFocusNode.requestFocus();
    });
  }

  // ── Penampil Foto Layar Penuh dengan fitur Pinch-to-Zoom (zoom in & out) ───
  void _openInteractiveImageViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.94),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // InteractiveViewer: mendukung gestur 2 jari untuk zoom in & out
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.5,
                    clipBehavior: Clip.none,
                    child: _buildImageWidget(fit: BoxFit.contain),
                  ),
                ),

                // Tombol Tutup di Pojok Kiri Atas
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            'Cubit untuk Zoom In / Out',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredComments {
    final Map<String, Map<String, dynamic>> commentMap = {
      for (final c in _comments) c['id'] as String: c,
    };

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

    final List<Map<String, dynamic>> mainComments = [];
    final Map<String, List<Map<String, dynamic>>> repliesByRootId = {};

    for (final c in _comments) {
      final replyToId = c['replyToId'] as String?;
      if (replyToId == null || !commentMap.containsKey(replyToId)) {
        mainComments.add(c);
      } else {
        final rootId = getRootCommentId(replyToId);
        repliesByRootId.putIfAbsent(rootId, () => []).add(c);
      }
    }

    if (_commentFilter == 'popular') {
      mainComments.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
    } else {
      mainComments.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    }

    final List<Map<String, dynamic>> result = [];
    for (final mainComment in mainComments) {
      result.add(mainComment);
      final replies = repliesByRootId[mainComment['id']];
      if (replies != null && replies.isNotEmpty) {
        replies.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
        result.addAll(replies);
      }
    }

    return result;
  }

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
    _persistComments();
  }

  void _showShareModal() {
    final shareApps = [
      {'name': 'WhatsApp', 'icon': Icons.chat_bubble_outline_rounded, 'color': const Color(0xFF25D366), 'bg': const Color(0xFFE8F5E9)},
      {'name': 'Instagram', 'icon': Icons.camera_alt_outlined, 'color': const Color(0xFFE1306C), 'bg': const Color(0xFFFCE4EC)},
      {'name': 'Facebook', 'icon': Icons.facebook, 'color': const Color(0xFF1877F2), 'bg': const Color(0xFFE3F2FD)},
      {'name': 'TikTok', 'icon': Icons.music_note_rounded, 'color': const Color(0xFF000000), 'bg': const Color(0xFFF1F5F9)},
      {'name': 'Salin Tautan', 'icon': Icons.link_rounded, 'color': const Color(0xFF1B5E3C), 'bg': const Color(0xFFE8F5E9)},
      {'name': 'Lainnya...', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF64748B), 'bg': const Color(0xFFF1F5F9)},
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                const Text('Pilih media sosial tujuan:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
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
                            Text(r['title']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(r['desc']!, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF1B5E3C), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Berhasil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3C),
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

  void _startReply(Map<String, dynamic> targetComment) {
    setState(() {
      _replyingToName = targetComment['name'] as String;
      _replyingToCommentId = targetComment['id'] as String;
    });
    if (_sheetController.isAttached && _sheetController.size < 0.3) {
      _sheetController.animateTo(0.65, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToName = null;
      _replyingToCommentId = null;
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Komentar minimal 3 karakter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
    _persistComments();
  }

  void _deleteCommentWithFade(Map<String, dynamic> comment) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Komentar?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        content: const Text('Komentar ini akan dihapus secara permanen dari postingan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
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
            _persistComments();
          }
        });
      }
    });
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E3C);
    final displayedComments = _filteredComments;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ─── 1. Foto Postingan Proporsional (Seperti di Beranda + Sentuh untuk Zoom) ───
          Positioned.fill(
            child: _buildBackgroundPhotoArea(),
          ),

          // ─── 2. Top Bar Melayang: Tombol Back Bundar & Kapsul "You" ───
          _buildTopHeader(),

          // ─── 3. Sliding White Sheet (DraggableScrollableSheet) ───
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.65,
            minChildSize: 0.10,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.10, 0.65, 0.95],
            builder: (context, scrollController) {
              // Simpan scrollController agar bisa digeser secara programatik
              _activeScrollController = scrollController;

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Column(
                    children: [
                      // ── Handle Bar / "Garis Kecil" di Atas Nama UKM ──
                      // Geser ke bawah atau sentuh untuk melihat foto secara penuh (full)
                      GestureDetector(
                        onTap: _toggleSheetExpand,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Konten Scrollable Sheet (Detail Postingan & Komentar) ──
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          children: [
                            // 1. Header UKM (Logo Bundar + Nama UKM)
                            _buildUkmHeader(primaryColor),
                            const SizedBox(height: 12),

                            // 2. Judul Postingan
                            _buildPostTitle(),
                            const SizedBox(height: 10),

                            // 3. Isi / Deskripsi Postingan
                            _buildPostContent(),
                            const SizedBox(height: 16),

                            // 4. Baris Kartu Statistik (❤️ 1067 | 💬 5    ⎋)
                            _buildStatsCard(),
                            const SizedBox(height: 18),

                            // 5. Header Komentar (Teks Komentar 5 + Tombol Filter Hijau)
                            _buildCommentsHeader(primaryColor),
                            const SizedBox(height: 14),

                            // 6. Daftar Komentar
                            for (final comment in displayedComments)
                              _buildAnimatedCommentItem(comment, primaryColor),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      // ── Bar Input Komentar Bawah (Hanya tampil saat sheet aktif, anti-overflow) ──
                      AnimatedBuilder(
                        animation: _sheetController,
                        builder: (context, _) {
                          final currentSize = _sheetController.isAttached
                              ? _sheetController.size
                              : 0.65;
                          if (currentSize < 0.22) {
                            return const SizedBox.shrink();
                          }
                          return _buildBottomCommentInput(primaryColor);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Area Foto Postingan Proporsional (Seperti Beranda)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBackgroundPhotoArea() {
    return GestureDetector(
      onTap: () => _openInteractiveImageViewer(context),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Latar belakang foto dengan reduksi kontras lembut
            Opacity(
              opacity: 0.35,
              child: _buildImageWidget(fit: BoxFit.cover),
            ),

            // Foto utama proporsional tanpa zoom in/out paksa (persis seperti di beranda)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.44,
              child: _buildImageWidget(fit: BoxFit.contain),
            ),

            // Gradien atas agar tombol Back & Kapsul "You" tetap kontras
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.70),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Indikator kecil petunjuk Zoom
            Positioned(
              top: MediaQuery.of(context).size.height * 0.34,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text(
                      'Tekan untuk Zoom',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget({required BoxFit fit}) {
    if (_postImageUrl != null) {
      return Image.network(
        _postImageUrl!,
        fit: fit,
        alignment: Alignment.center,
        errorBuilder: (_, _, _) => _buildDefaultGraphicBanner(const Color(0xFF1B5E3C)),
      );
    }
    if (_post?.assetImagePath != null) {
      return Image.asset(
        _post!.assetImagePath!,
        fit: fit,
        alignment: Alignment.center,
        errorBuilder: (_, _, _) => _buildDefaultGraphicBanner(const Color(0xFF1B5E3C)),
      );
    }
    return _buildDefaultGraphicBanner(const Color(0xFF1B5E3C));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Top Bar Melayang
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile, arguments: true);
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentDisplayTitleName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const ProfileAvatar(radius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Header UKM di dalam Lembar Putih
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildUkmHeader(Color primaryColor) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/logoneo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Icon(
                    _post?.icon ?? Icons.psychology,
                    color: Colors.white,
                    size: 20,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _post?.authorName ?? 'Neo Telemetri',
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Judul & Isi Postingan
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPostTitle() {
    return Text(
      _post?.title ?? 'Postingan Dibuat buat Sembrono oleh Rezim, Gibran : Knock satu cik',
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
        height: 1.25,
      ),
    );
  }

  Widget _buildPostContent() {
    final text = _post?.description.isNotEmpty == true
        ? _post!.description
        : (_post?.fullContent ?? '');

    return Text(
      text.isNotEmpty
          ? text
          : 'Bahaya banget loh yaa, kejadian yang tidak diduga terjadi pada awal bulan ini secara mendadak, pihak aparat mengambil tindakan krusial dengan tidur untuk membangun mimpi yang ada di angan” mereka, masyarakat setuju dan membiarkan masalah ini menjadi pelajaran dan menggangap hanya ujian yang diberikan',
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF1E293B),
        height: 1.45,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. Baris Kartu Statistik (❤️ 1067 | 💬 5    ⎋)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Heart Like Post
          GestureDetector(
            onTap: _togglePostLike,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFE53935),
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_likeCount',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Garis Pembatas Vertikal
          Container(
            width: 1.2,
            height: 20,
            color: const Color(0xFFCBD5E1),
          ),
          const SizedBox(width: 14),

          // Ikon & Jumlah Komentar -> Klik untuk otomatis geser ke bawah tempat komentar!
          GestureDetector(
            onTap: _scrollToComments,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_comments.length}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol Share
          GestureDetector(
            onTap: _showShareModal,
            child: const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. Header Komentar (Komentar 5 + Filter Hijau)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCommentsHeader(Color primaryColor) {
    return Row(
      children: [
        const Text(
          'Komentar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_comments.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
          ),
        ),
        const Spacer(),

        // Tombol Bulat Hijau Filter (Terpopuler / Terbaru)
        PopupMenuButton<String>(
          initialValue: _commentFilter,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 7. Item Komentar dengan Like di Kanan & Tombol Balas / Lapor di Bawah
  // ─────────────────────────────────────────────────────────────────────────────
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
          left: isReply ? 24 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (!isMe && !isOrganizer)
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.profile,
                            arguments: false,
                          );
                        }
                      : null,
                  child: CircleAvatar(
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
                              color: isMe ? const Color(0xFF1B5E3C) : const Color(0xFF1E293B),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
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
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B5E3C),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Anda',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isOrganizer) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Penyelenggara',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c['content'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () => _toggleCommentLike(c),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLikedByMe ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isLikedByMe ? const Color(0xFFE53935) : const Color(0xFF94A3B8),
                              ),
                              if (likesCount > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$likesCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLikedByMe ? const Color(0xFFE53935) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: isReply ? 42 : 46, top: 4),
              child: Row(
                children: [
                  Text(
                    c['time'] as String,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: () => _startReply(c),
                    child: Text(
                      'Balas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: () => _reportComment(c),
                    child: const Icon(
                      Icons.outlined_flag_rounded,
                      size: 15,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 14),
                    InkWell(
                      onTap: () => _deleteCommentWithFade(c),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 15,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 8. Bar Input Komentar Bawah (Anti-Overflow)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBottomCommentInput(Color primaryColor) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // Gunakan padding aman agar tidak overflow saat keyboard atau bilah navigasi aktif
    final safeBottomPadding = bottomInset > 0 ? 8.0 : 8.0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: primaryColor, width: 3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 16, color: primaryColor),
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
              const ProfileAvatar(radius: 18),
              const SizedBox(width: 8),
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
                  decoration: BoxDecoration(
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Banner grafis default jika postingan tidak memiliki file gambar
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildDefaultGraphicBanner(Color primaryColor) {
    final gradient = _post?.bannerGradient ?? const [Color(0xFF004528), Color(0xFF1B6D24)];
    final icon = _post?.bannerIcon ?? Icons.workspace_premium;
    final title = _post?.bannerTitle ?? 'POSTINGAN KAMPUS UNAND';
    final subtitle = _post?.bannerSubtitle ?? 'UKM HUB UNIVERSITAS ANDALAS';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: gradient.first,
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
              size: 200,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: const Color(0xFFFACC15)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF93D5AA),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
