import 'package:image_picker/image_picker.dart' show XFile;
import '../models/oprec_post.dart';
import '../models/registration.dart';

/// Error yang pesannya aman ditampilkan langsung ke user.
class RegistrationException implements Exception {
  final String message;
  const RegistrationException(this.message);
}

/// Pintu tunggal layar oprec ke data. Implementasinya bisa data palsu atau
/// API; layar tidak perlu tahu bedanya.
abstract class OprecRepository {
  /// GET /oprec
  Future<List<OprecPost>> fetchOprecPosts({bool onlyOpen = false});

  /// GET /oprec/{post_id}
  Future<OprecPost> fetchOprecPost(String postId);

  /// POST /oprec/{post_id}/registrations. [files] berkunci [RequiredFile.id];
  /// semua slot yang wajib harus terisi.
  Future<Registration> submitRegistration({
    required OprecPost post,
    required String name,
    required String nim,
    required String prodi,
    required String whatsapp,
    required String motivation,
    required Map<String, XFile> files,
  });

  /// GET /registrations (terbaru lebih dulu, termasuk yang dibatalkan)
  Future<List<Registration>> fetchMyRegistrations();

  /// GET /registrations/{id}, lengkap dengan riwayat status
  Future<Registration> fetchRegistration(String id);

  /// PATCH /registrations/{id}; field null berarti tidak diubah, dan [files]
  /// hanya mengganti slot yang ada di dalamnya.
  Future<Registration> updateRegistration(
    String id, {
    String? name,
    String? nim,
    String? prodi,
    String? whatsapp,
    String? motivation,
    Map<String, XFile>? files,
  });

  /// DELETE /registrations/{id}; status menjadi dibatalkan, data tidak dihapus.
  Future<void> cancelRegistration(String id);
}
