import '../../../models/user.dart';

/// Akun dummy untuk uji coba login selama backend REST API asli belum
/// tersedia.
/// TODO: hapus setelah endpoint POST /auth/login siap dipakai.
class DummyAccount {
  DummyAccount._();

  static const String email = 'lutfihazelm@gmail.com';
  static const String password = '12345678';

  static const User user = User(
    id: 'dummy-001',
    nama: 'Annisa Putri',
    nim: '2110112233',
    email: email,
    noHp: '081234567890',
  );
}
