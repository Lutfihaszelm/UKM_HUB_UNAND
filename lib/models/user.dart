/// Mahasiswa (User) model per PRD section 2.5 — Data Requirements.
/// Satu jenis akun untuk seluruh pengguna; hak kelola UKM ditentukan
/// lewat relasi kepengurusan (UKM_Admin), bukan field di model ini.
class User {
  const User({
    required this.id,
    required this.nama,
    required this.nim,
    required this.email,
    required this.noHp,
  });

  final String id;
  final String nama;
  final String nim;
  final String email;
  final String noHp;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      nama: json['nama'] as String,
      nim: json['nim'] as String,
      email: json['email'] as String,
      noHp: json['no_hp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'email': email,
      'no_hp': noHp,
    };
  }
}
