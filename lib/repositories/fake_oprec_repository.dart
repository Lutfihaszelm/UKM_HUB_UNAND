// lib/repositories/fake_oprec_repository.dart
import 'package:file_picker/file_picker.dart';
import '../models/oprec_post.dart';
import '../models/registration.dart';
import 'oprec_repository.dart';

class FakeOprecRepository implements OprecRepository {
  final bool simulateNetworkError;
  FakeOprecRepository({this.simulateNetworkError = false});

  final List<Registration> _store = [];

  @override
  Future<Registration> submitRegistration({
    required OprecPost post,
    required String motivation,
    required PlatformFile file,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi loading

    if (simulateNetworkError) {
      throw const RegistrationException(
        'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
      );
    }
    if (post.isClosed) {
      throw const RegistrationException('Pendaftaran sudah ditutup.');
    }
    if (_store.any((r) => r.postId == post.id)) {
      throw const RegistrationException(
        'Kamu sudah mendaftar di open recruitment ini.',
      );
    }

    final registration = Registration(
      id: 'reg-${DateTime.now().millisecondsSinceEpoch}',
      postId: post.id,
      motivation: motivation,
      fileName: file.name,
      status: 'Menunggu',
      createdAt: DateTime.now(),
    );
    _store.add(registration);
    return registration;
  }
}