import 'package:file_picker/file_picker.dart';
import '../models/oprec_post.dart';
import '../models/registration.dart';

/// Error yang pesannya aman ditampilkan langsung ke user.
class RegistrationException implements Exception {
  final String message;
  const RegistrationException(this.message);
}

abstract class OprecRepository {
  Future<Registration> submitRegistration({
    required OprecPost post,
    required String motivation,
    required PlatformFile file,
  });
}