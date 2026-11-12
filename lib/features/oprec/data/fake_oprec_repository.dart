// lib/repositories/fake_oprec_repository.dart
import 'package:image_picker/image_picker.dart' show XFile;
import '../models/oprec_post.dart';
import '../models/registration.dart';
import 'oprec_repository.dart';

/// Repository data palsu (sebelum backend siap). Aturan dan pesan error
/// disamakan dengan API, jadi layar tidak berubah saat repository diganti.
class FakeOprecRepository implements OprecRepository {
  final bool simulateNetworkError;

  /// Lama simulasi loading; test memakai Duration.zero.
  final Duration latency;

  FakeOprecRepository({
    this.simulateNetworkError = false,
    this.latency = const Duration(seconds: 2),
    List<OprecPost> posts = const [],
  }) : _posts = {for (final post in posts) post.id: post};

  final Map<String, OprecPost> _posts;
  final List<Registration> _store = [];

  // Pesan sama dengan kolom "Pesan" di tabel kode error API contract.
  static const _notFound = 'Data tidak ditemukan.';
  static const _closed = 'Pendaftaran sudah ditutup.';
  static const _locked = 'Pendaftaran tidak bisa diubah karena sudah diproses.';
  static const _invalid = 'Data pendaftaran belum valid.';

  Future<void> _simulateRequest() async {
    await Future.delayed(latency); // simulasi loading
    if (simulateNetworkError) {
      throw const RegistrationException(
        'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
      );
    }
  }

  int _indexOf(String id) {
    final index = _store.indexWhere((r) => r.id == id);
    if (index == -1) throw const RegistrationException(_notFound);
    return index;
  }

  bool _isClosed(String postId) => _posts[postId]?.isClosed ?? false;

  /// can_modify dihitung saat dibaca, seperti di server.
  Registration _view(Registration r) => r.copyWith(
        canModify:
            r.status == RegistrationStatus.menunggu && !_isClosed(r.postId),
      );

  /// Pastikan pendaftaran masih boleh diedit / dibatalkan.
  void _ensureModifiable(Registration r) {
    if (r.status != RegistrationStatus.menunggu) {
      throw const RegistrationException(_locked);
    }
    if (_isClosed(r.postId)) throw const RegistrationException(_closed);
  }

  /// Simpan metadata berkas per slot; slot yang tidak dikenal ditolak (422).
  Future<List<RegistrationFile>> _toRegistrationFiles(
    OprecPost post,
    Map<String, XFile> files,
  ) async {
    final result = <RegistrationFile>[];
    for (final entry in files.entries) {
      final slot = post.requiredFiles.where((f) => f.id == entry.key);
      if (slot.isEmpty) throw const RegistrationException(_invalid);
      result.add(RegistrationFile(
        requiredFileId: entry.key,
        label: slot.first.label,
        name: entry.value.name,
        sizeBytes: await entry.value.length(),
        mime: _mimeOf(entry.value.name),
      ));
    }
    return result;
  }

  static String _mimeOf(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'application/pdf';
    if (name.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  @override
  Future<List<OprecPost>> fetchOprecPosts({bool onlyOpen = false}) async {
    await _simulateRequest();
    return _posts.values.where((p) => !onlyOpen || !p.isClosed).toList();
  }

  @override
  Future<OprecPost> fetchOprecPost(String postId) async {
    await _simulateRequest();
    final post = _posts[postId];
    if (post == null) throw const RegistrationException(_notFound);
    return post;
  }

  @override
  Future<Registration> submitRegistration({
    required OprecPost post,
    required String name,
    required String nim,
    required String prodi,
    required String whatsapp,
    required String motivation,
    required Map<String, XFile> files,
  }) async {
    await _simulateRequest();

    if (post.isClosed) {
      throw const RegistrationException(_closed);
    }
    if (post.requiredFiles.any((f) => f.isRequired && !files.containsKey(f.id))) {
      throw const RegistrationException(_invalid);
    }
    // Satu pendaftaran aktif per oprec; yang dibatalkan tidak dihitung.
    if (_store.any((r) =>
        r.postId == post.id && r.status != RegistrationStatus.dibatalkan)) {
      throw const RegistrationException(
        'Kamu sudah mendaftar di open recruitment ini.',
      );
    }

    final registrationFiles = await _toRegistrationFiles(post, files);
    _posts.putIfAbsent(post.id, () => post);
    final now = DateTime.now();
    final registration = Registration(
      id: 'reg-${now.microsecondsSinceEpoch}',
      postId: post.id,
      name: name,
      nim: nim,
      prodi: prodi,
      whatsapp: whatsapp,
      motivation: motivation,
      files: registrationFiles,
      status: RegistrationStatus.menunggu,
      canModify: true,
      createdAt: now,
      updatedAt: now,
      history: [
        StatusChange(
          fromStatus: null,
          toStatus: RegistrationStatus.menunggu,
          changedBy: 'mahasiswa',
          changedAt: now,
        ),
      ],
    );
    _store.add(registration);
    return _view(registration);
  }

  @override
  Future<List<Registration>> fetchMyRegistrations() async {
    await _simulateRequest();
    final list = _store.map(_view).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Registration> fetchRegistration(String id) async {
    await _simulateRequest();
    return _view(_store[_indexOf(id)]);
  }

  @override
  Future<Registration> updateRegistration(
    String id, {
    String? name,
    String? nim,
    String? prodi,
    String? whatsapp,
    String? motivation,
    Map<String, XFile>? files,
  }) async {
    await _simulateRequest();
    final index = _indexOf(id);
    final current = _store[index];
    _ensureModifiable(current);

    // Berkas baru menggantikan berkas lama di slot yang sama.
    List<RegistrationFile>? mergedFiles;
    if (files != null) {
      final post = _posts[current.postId]!;
      final replaced = await _toRegistrationFiles(post, files);
      mergedFiles = [
        ...current.files.where((f) => !files.containsKey(f.requiredFileId)),
        ...replaced,
      ];
    }

    final updated = current.copyWith(
      name: name,
      nim: nim,
      prodi: prodi,
      whatsapp: whatsapp,
      motivation: motivation,
      files: mergedFiles,
      updatedAt: DateTime.now(),
    );
    _store[index] = updated;
    return _view(updated);
  }

  @override
  Future<void> cancelRegistration(String id) async {
    await _simulateRequest();
    final index = _indexOf(id);
    final current = _store[index];
    _ensureModifiable(current);

    final now = DateTime.now();
    _store[index] = current.copyWith(
      status: RegistrationStatus.dibatalkan,
      updatedAt: now,
      cancelledAt: now,
      history: [
        ...current.history,
        StatusChange(
          fromStatus: current.status,
          toStatus: RegistrationStatus.dibatalkan,
          changedBy: 'mahasiswa',
          changedAt: now,
        ),
      ],
    );
  }

  /// Pengganti PATCH /admin/registrations/{id}/status selama belum ada
  /// backend. Bukan bagian [OprecRepository]: mahasiswa tidak bisa memakainya.
  void simulateAdminStatusChange(
    String id,
    RegistrationStatus status, {
    String? note,
  }) {
    final index = _indexOf(id);
    final current = _store[index];
    final now = DateTime.now();
    _store[index] = current.copyWith(
      status: status,
      updatedAt: now,
      history: [
        ...current.history,
        StatusChange(
          fromStatus: current.status,
          toStatus: status,
          note: note,
          changedBy: 'admin',
          changedAt: now,
        ),
      ],
    );
  }
}
