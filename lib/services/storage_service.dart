// lib/services/storage_service.dart
// ===========================================================================
// StorageService — Persistensi Data Lokal (shared_preferences + JSON)
// Menyimpan: data login, komentar, like postingan, like komentar, laporan.
// ===========================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // ─── Key constants ───────────────────────────────────────────────────────
  static const _kLoggedIn      = 'auth_is_logged_in';
  static const _kUsername      = 'auth_username';
  static const _kEmail         = 'auth_email';
  static const _kAvatarInitial = 'auth_avatar_initial';

  static const _kPostLiked    = 'post_liked_'; // + postId
  static const _kPostLikeCount = 'post_like_count_'; // + postId

  static const _kComments     = 'comments_'; // + postId  → JSON list
  static const _kCommentLikes = 'comment_likes_'; // + postId → JSON map {id: count}
  static const _kCommentLikedByMe = 'comment_liked_me_'; // + postId → JSON set [ids]

  static const _kReports      = 'reports_'; // + postId → JSON list

  // ─── Instance ────────────────────────────────────────────────────────────
  late SharedPreferences _prefs;

  /// Harus dipanggil satu kali di main() sebelum runApp.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===========================================================================
  // AUTH
  // ===========================================================================

  Future<void> saveLoginSession({
    required String username,
    required String email,
    required String avatarInitial,
  }) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kUsername, username);
    await _prefs.setString(_kEmail, email);
    await _prefs.setString(_kAvatarInitial, avatarInitial);
  }

  Future<void> clearLoginSession() async {
    await _prefs.remove(_kLoggedIn);
    await _prefs.remove(_kUsername);
    await _prefs.remove(_kEmail);
    await _prefs.remove(_kAvatarInitial);
  }

  bool get isLoggedIn => _prefs.getBool(_kLoggedIn) ?? false;
  String get username  => _prefs.getString(_kUsername) ?? 'Pengguna';
  String get email     => _prefs.getString(_kEmail) ?? '';
  String get avatarInitial => _prefs.getString(_kAvatarInitial) ?? 'U';

  // ===========================================================================
  // LIKE POSTINGAN
  // ===========================================================================

  bool isPostLiked(String postId) =>
      _prefs.getBool('$_kPostLiked$postId') ?? false;

  int getPostLikeCount(String postId, {int defaultCount = 0}) =>
      _prefs.getInt('$_kPostLikeCount$postId') ?? defaultCount;

  Future<void> togglePostLike(String postId, {required int currentCount}) async {
    final liked = isPostLiked(postId);
    await _prefs.setBool('$_kPostLiked$postId', !liked);
    await _prefs.setInt(
      '$_kPostLikeCount$postId',
      liked ? currentCount - 1 : currentCount + 1,
    );
  }

  // ===========================================================================
  // KOMENTAR
  // ===========================================================================

  /// Simpan seluruh list komentar untuk sebuah postingan.
  Future<void> saveComments(String postId, List<Map<String, dynamic>> comments) async {
    // Konversi DateTime menjadi int (millisecondsSinceEpoch) agar JSON-safe.
    final safeList = comments.map((c) {
      final copy = Map<String, dynamic>.from(c);
      if (copy['timestamp'] is DateTime) {
        copy['timestamp'] = (copy['timestamp'] as DateTime).millisecondsSinceEpoch;
      }
      return copy;
    }).toList();
    await _prefs.setString('$_kComments$postId', jsonEncode(safeList));
  }

  /// Baca list komentar dari storage. Mengembalikan null jika belum ada data.
  List<Map<String, dynamic>>? loadComments(String postId) {
    final raw = _prefs.getString('$_kComments$postId');
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Mengembalikan jumlah komentar tersimpan untuk sebuah postingan.
  /// Jika belum ada data tersimpan, kembalikan [defaultCount].
  int getCommentCount(String postId, {int defaultCount = 0}) {
    final raw = _prefs.getString('$_kComments$postId');
    if (raw == null) return defaultCount;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.length;
  }

  // ===========================================================================
  // LIKE KOMENTAR
  // ===========================================================================

  /// Simpan state like semua komentar pada sebuah postingan.
  /// [likeMap] : { commentId: likeCount }
  /// [likedByMeIds] : set of commentIds yang dilike oleh user saat ini.
  Future<void> saveCommentLikes(
    String postId, {
    required Map<String, int> likeMap,
    required Set<String> likedByMeIds,
  }) async {
    await _prefs.setString('$_kCommentLikes$postId', jsonEncode(likeMap));
    await _prefs.setString(
      '$_kCommentLikedByMe$postId',
      jsonEncode(likedByMeIds.toList()),
    );
  }

  Map<String, int> loadCommentLikeCounts(String postId) {
    final raw = _prefs.getString('$_kCommentLikes$postId');
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  Set<String> loadCommentLikedByMe(String postId) {
    final raw = _prefs.getString('$_kCommentLikedByMe$postId');
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<String>().toSet();
  }

  // ===========================================================================
  // LAPORAN KOMENTAR
  // ===========================================================================

  Future<void> addReport(String postId, {
    required String commentId,
    required String reason,
    required String reportedBy,
  }) async {
    final raw = _prefs.getString('$_kReports$postId');
    final List<dynamic> list = raw != null ? jsonDecode(raw) as List : [];
    list.add({
      'commentId': commentId,
      'reason': reason,
      'reportedBy': reportedBy,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await _prefs.setString('$_kReports$postId', jsonEncode(list));
  }

  List<Map<String, dynamic>> loadReports(String postId) {
    final raw = _prefs.getString('$_kReports$postId');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Hapus semua data tersimpan (misalnya saat logout).
  Future<void> clearAll() async => _prefs.clear();
}
