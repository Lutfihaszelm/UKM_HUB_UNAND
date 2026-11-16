import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import 'package:ukm_hub/features/oprec/data/fake_oprec_repository.dart';
import 'package:ukm_hub/features/oprec/data/oprec_repository.dart';
import 'package:ukm_hub/features/oprec/models/oprec_post.dart';
import 'package:ukm_hub/features/oprec/models/registration.dart';

/// Berkas di memori; path tanpa folder supaya nama sama di semua OS.
XFile _file(String name, int size) => XFile.fromData(Uint8List(size), path: name);

const _slots = [
  RequiredFile(id: 'foto', label: 'Pas Foto', accept: FileAccept.image),
  RequiredFile(id: 'cv', label: 'CV', accept: FileAccept.pdf),
  RequiredFile(
    id: 'extra',
    label: 'Dokumen Tambahan',
    accept: FileAccept.pdf,
    isRequired: false,
  ),
];

final _openPost = OprecPost(
  id: 'oprec-buka',
  ukmName: 'UKM Buka',
  logoUKM: null,
  title: 'Oprec Buka',
  description: 'Masih dibuka',
  closeDate: DateTime.now().add(const Duration(days: 7)),
  requiredFiles: _slots,
);

final _closedPost = OprecPost(
  id: 'oprec-tutup',
  ukmName: 'UKM Tutup',
  logoUKM: null,
  title: 'Oprec Tutup',
  description: 'Sudah ditutup',
  closeDate: DateTime.now().subtract(const Duration(days: 1)),
  requiredFiles: _slots,
);

FakeOprecRepository _repo({bool networkError = false}) => FakeOprecRepository(
      latency: Duration.zero,
      simulateNetworkError: networkError,
      posts: [_openPost, _closedPost],
    );

Future<Registration> _submit(
  OprecRepository repo, {
  OprecPost? post,
  Map<String, XFile>? files,
}) =>
    repo.submitRegistration(
      post: post ?? _openPost,
      name: 'Nama Mahasiswa',
      nim: '2411520000',
      prodi: 'Sistem Informasi',
      whatsapp: '081234567890',
      motivation: 'Saya ingin belajar dan berkontribusi.',
      files: files ??
          {'foto': _file('foto.jpg', 1024), 'cv': _file('cv.pdf', 2048)},
    );

Matcher _throwsMessage(String message) => throwsA(
    isA<RegistrationException>().having((e) => e.message, 'message', message));

void main() {
  group('FakeOprecRepository', () {
    test('daftar oprec bisa difilter yang masih dibuka', () async {
      final repo = _repo();
      expect(await repo.fetchOprecPosts(), hasLength(2));
      expect((await repo.fetchOprecPosts(onlyOpen: true)).map((p) => p.id),
          ['oprec-buka']);
      expect((await repo.fetchOprecPost('oprec-tutup')).isClosed, isTrue);
      expect(repo.fetchOprecPost('tidak-ada'),
          _throwsMessage('Data tidak ditemukan.'));
    });

    test('mendaftar menyimpan prodi, WhatsApp, berkas per slot, dan riwayat',
        () async {
      final r = await _submit(_repo());

      expect(r.prodi, 'Sistem Informasi');
      expect(r.whatsapp, '081234567890');
      expect(r.status, RegistrationStatus.menunggu);
      expect(r.canModify, isTrue);
      expect(r.history.single.fromStatus, isNull);
      expect(r.history.single.toStatus, RegistrationStatus.menunggu);

      final foto = r.files.firstWhere((f) => f.requiredFileId == 'foto');
      expect(foto.label, 'Pas Foto');
      expect(foto.name, 'foto.jpg');
      expect(foto.sizeBytes, 1024);
      expect(foto.mime, 'image/jpeg');
      expect(r.files.map((f) => f.mime), contains('application/pdf'));
    });

    test('slot wajib yang kosong atau slot tak dikenal ditolak', () async {
      final repo = _repo();
      const invalid = 'Data pendaftaran belum valid.';

      expect(_submit(repo, files: {'foto': _file('foto.jpg', 10)}),
          _throwsMessage(invalid));
      expect(
          _submit(repo, files: {
            'foto': _file('foto.jpg', 10),
            'cv': _file('cv.pdf', 10),
            'asing': _file('x.pdf', 10),
          }),
          _throwsMessage(invalid));
    });

    test('menolak daftar dua kali dan oprec yang sudah ditutup', () async {
      final repo = _repo();
      await _submit(repo);

      expect(_submit(repo),
          _throwsMessage('Kamu sudah mendaftar di open recruitment ini.'));
      expect(_submit(repo, post: _closedPost),
          _throwsMessage('Pendaftaran sudah ditutup.'));
    });

    test('edit saat menunggu hanya mengganti field dan slot yang diisi',
        () async {
      final repo = _repo();
      final r = await _submit(repo);

      final updated = await repo.updateRegistration(
        r.id,
        prodi: 'Informatika',
        files: {'cv': _file('cv-baru.pdf', 4096)},
      );

      expect(updated.prodi, 'Informatika');
      expect(updated.name, r.name);
      expect(updated.files, hasLength(2));
      expect(updated.files.map((f) => f.name),
          containsAll(['foto.jpg', 'cv-baru.pdf']));
      expect((await repo.fetchRegistration(r.id)).prodi, 'Informatika');
    });

    test('batal mengubah status jadi dibatalkan dan boleh daftar lagi',
        () async {
      final repo = _repo();
      final r = await _submit(repo);

      await repo.cancelRegistration(r.id);
      final cancelled = await repo.fetchRegistration(r.id);

      expect(cancelled.status, RegistrationStatus.dibatalkan);
      expect(cancelled.cancelledAt, isNotNull);
      expect(cancelled.canModify, isFalse);
      expect(cancelled.history.last.fromStatus, RegistrationStatus.menunggu);
      expect(cancelled.history.last.toStatus, RegistrationStatus.dibatalkan);

      final again = await _submit(repo);
      final mine = await repo.fetchMyRegistrations();
      expect(mine.map((x) => x.id), [again.id, r.id]); // terbaru lebih dulu
    });

    test('edit dan batal ditolak setelah status diproses admin', () async {
      final repo = _repo();
      final r = await _submit(repo);
      repo.simulateAdminStatusChange(r.id, RegistrationStatus.seleksi);

      const locked = 'Pendaftaran tidak bisa diubah karena sudah diproses.';
      expect(repo.updateRegistration(r.id, prodi: 'Informatika'),
          _throwsMessage(locked));
      expect(repo.cancelRegistration(r.id), _throwsMessage(locked));

      final current = await repo.fetchRegistration(r.id);
      expect(current.canModify, isFalse);
      expect(current.history.last.changedBy, 'admin');
    });

    test('pendaftaran yang tidak ada menghasilkan pesan 404', () async {
      final repo = _repo();
      expect(repo.fetchRegistration('tidak-ada'),
          _throwsMessage('Data tidak ditemukan.'));
      expect(repo.cancelRegistration('tidak-ada'),
          _throwsMessage('Data tidak ditemukan.'));
    });

    test('gangguan jaringan memakai pesan koneksi', () async {
      expect(
          _repo(networkError: true).fetchMyRegistrations(),
          _throwsMessage(
              'Tidak dapat terhubung ke server. Periksa koneksi internetmu.'));
    });
  });
}
