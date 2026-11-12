import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/features/oprec/models/oprec_post.dart';
import 'package:ukm_hub/features/oprec/models/registration.dart';

/// Contoh objek Registration dari docs/modul3.md (endpoint 5, lengkap),
/// ditambah usulan `whatsapp` dan `files` (slot berkas dinamis per oprec).
Map<String, dynamic> _registrationJson() => {
      'id': '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      'post_id': 'b1f0c2a4-6d7e-4a3b-9c55-2f1e8d0a7b11',
      'full_name': 'Nama Mahasiswa',
      'nim': '2411520000',
      'prodi': 'Sistem Informasi',
      'whatsapp': '081234567890',
      'motivation': 'Saya ingin belajar dan berkontribusi di UKM ini...',
      'status': 'seleksi',
      'files': [
        {
          'required_file_id': 'f-foto',
          'label': 'Pas Foto',
          'name': 'foto.jpg',
          'size_bytes': 184320,
          'mime': 'image/jpeg',
          'download_url': '/api/v1/registrations/7c9e6679/files/f-foto',
        },
        {
          'required_file_id': 'f-cv',
          'label': 'CV',
          'name': 'cv.pdf',
          'size_bytes': 92160,
          'mime': 'application/pdf',
          'download_url': '/api/v1/registrations/7c9e6679/files/f-cv',
        },
      ],
      'can_modify': false,
      'submitted_at': '2026-11-05T05:12:00Z',
      'updated_at': '2026-11-07T02:00:00Z',
      'cancelled_at': null,
      'history': [
        {
          'from_status': null,
          'to_status': 'menunggu',
          'note': null,
          'changed_by': 'mahasiswa',
          'changed_at': '2026-11-05T05:12:00Z',
        },
        {
          'from_status': 'menunggu',
          'to_status': 'seleksi',
          'note': null,
          'changed_by': 'admin',
          'changed_at': '2026-11-07T02:00:00Z',
        },
      ],
    };

void main() {
  group('RegistrationStatus', () {
    test('punya enam status, termasuk dibatalkan', () {
      expect(RegistrationStatus.values, hasLength(6));
      expect(RegistrationStatus.dibatalkan.label, 'Dibatalkan');
    });

    test('fromServer memetakan semua nilai enum server', () {
      const server = [
        'menunggu',
        'seleksi',
        'wawancara',
        'diterima',
        'ditolak',
        'dibatalkan',
      ];
      for (final value in server) {
        expect(RegistrationStatus.fromServer(value).name, value);
      }
    });

    test('fromServer menolak nilai yang tidak dikenal', () {
      expect(() => RegistrationStatus.fromServer('Menunggu'),
          throwsFormatException);
    });
  });

  group('Registration.fromJson', () {
    test('memetakan seluruh field objek Registration', () {
      final r = Registration.fromJson(_registrationJson());

      expect(r.id, '7c9e6679-7425-40de-944b-e07fc1f90ae7');
      expect(r.postId, 'b1f0c2a4-6d7e-4a3b-9c55-2f1e8d0a7b11');
      expect(r.name, 'Nama Mahasiswa');
      expect(r.nim, '2411520000');
      expect(r.prodi, 'Sistem Informasi');
      expect(r.whatsapp, '081234567890');
      expect(r.files, hasLength(2));
      expect(r.files.first.requiredFileId, 'f-foto');
      expect(r.files.first.label, 'Pas Foto');
      expect(r.files.first.sizeBytes, 184320);
      expect(r.files.last.mime, 'application/pdf');
      expect(r.status, RegistrationStatus.seleksi);
      expect(r.canModify, isFalse);
      expect(r.createdAt, DateTime.utc(2026, 11, 5, 5, 12));
      expect(r.updatedAt, DateTime.utc(2026, 11, 7, 2));
      expect(r.cancelledAt, isNull);
    });

    test('memetakan riwayat status', () {
      final history = Registration.fromJson(_registrationJson()).history;

      expect(history, hasLength(2));
      expect(history.first.fromStatus, isNull);
      expect(history.first.toStatus, RegistrationStatus.menunggu);
      expect(history.first.changedBy, 'mahasiswa');
      expect(history.last.fromStatus, RegistrationStatus.menunggu);
      expect(history.last.toStatus, RegistrationStatus.seleksi);
      expect(history.last.changedBy, 'admin');
    });

    test('pendaftaran dibatalkan dan tanpa history (bentuk daftar)', () {
      final json = _registrationJson()
        ..['status'] = 'dibatalkan'
        ..['cancelled_at'] = '2026-11-06T01:00:00Z'
        ..remove('history');
      final r = Registration.fromJson(json);

      expect(r.status, RegistrationStatus.dibatalkan);
      expect(r.cancelledAt, DateTime.utc(2026, 11, 6, 1));
      expect(r.history, isEmpty);
    });
  });

  group('RequiredFile', () {
    test('fromJson memetakan slot berkas oprec', () {
      final slot = RequiredFile.fromJson({
        'id': 'f-ktm',
        'label': 'KTM',
        'accept': 'image',
        'is_required': false,
      });

      expect(slot.id, 'f-ktm');
      expect(slot.label, 'KTM');
      expect(slot.accept, FileAccept.image);
      expect(slot.isRequired, isFalse);
    });

    test('FileAccept: ekstensi dan kamera', () {
      expect(FileAccept.fromServer('pdf'), FileAccept.pdf);
      expect(FileAccept.image.extensions, containsAll(['jpg', 'jpeg', 'png']));
      expect(FileAccept.image.allowsCamera, isTrue);
      expect(FileAccept.any.allowsCamera, isTrue);
      expect(FileAccept.pdf.allowsCamera, isFalse);
      expect(() => FileAccept.fromServer('video'), throwsFormatException);
    });
  });
}
