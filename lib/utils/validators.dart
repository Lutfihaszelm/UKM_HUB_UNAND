/// Kumpulan fungsi validasi yang bisa dipakai ulang (reusable).
/// Aturan validator di Flutter:
/// - return null -> input VALID
/// - return 'pesan' -> input TIDAK VALID, pesan tampil di bawah field
class Validators {
 Validators._();
 static String? requiredField(String? value, {String fieldName = 'Field ini'}) {
 if (value == null || value.trim().isEmpty) {
 return '$fieldName wajib diisi';
 }
 return null;
 }

 static String? email(String? value) {
 final requiredError = requiredField(value, fieldName: 'Email');
 if (requiredError != null) return requiredError;
 final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
 if (!emailRegex.hasMatch(value!.trim())) {
 return 'Format email tidak valid';
 }
 return null;
 }
 static String? password(String? value) {
 if (value == null || value.isEmpty) return 'Password wajib diisi';
 if (value.length < 8) return 'Password minimal 8 karakter';
 return null;
 }
 static String? minLength(
 String? value,
 int min, {
 String fieldName = 'Field ini',
 }) {
 final requiredError = requiredField(value, fieldName: fieldName);
 if (requiredError != null) return requiredError;
 if (value!.trim().length < min) {
 return '$fieldName minimal $min karakter';
 }
 return null;
 }
 static String? rating(String? value) {
 final requiredError = requiredField(value, fieldName: 'Rating');
 if (requiredError != null) return requiredError;
 final number = int.tryParse(value!.trim());
 if (number == null) return 'Rating harus berupa angka';
 if (number < 1 || number > 5) return 'Rating harus di antara 1 sampai 5';
 return null;
 }

  // ---------- Validator form Open Recruitment (Modul 3) ----------

  // Batas panjang disamakan dengan aturan field di API contract.
  static String? _lengthBetween(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    final length = value!.trim().length;
    if (length < min) return 'Minimal $min karakter (sekarang $length)';
    if (length > max) return 'Maksimal $max karakter (sekarang $length)';
    return null;
  }

  static String? name(String? value) => _lengthBetween(value, 3, 100, 'Nama');

  static String? prodi(String? value) =>
      _lengthBetween(value, 2, 100, 'Program studi');

  static String? nim(String? value) {
    final requiredError = requiredField(value, fieldName: 'NIM');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^\d{10}$').hasMatch(value!.trim())) {
      return 'NIM harus 10 digit angka';
    }
    return null;
  }

  /// Nomor Indonesia: 08..., 628..., atau +628...; 10 sampai 13 digit bila
  /// diawali 08. Sama dengan CHECK `whatsapp` di API contract.
  static String? whatsapp(String? value) {
    final requiredError = requiredField(value, fieldName: 'No. WhatsApp');
    if (requiredError != null) return requiredError;
    final number = value!.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+62|62|0)8\d{8,11}$').hasMatch(number)) {
      return 'Nomor WhatsApp tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? motivation(String? value) =>
      _lengthBetween(value, 20, 1000, 'Motivasi');
}
