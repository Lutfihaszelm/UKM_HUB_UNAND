import 'package:flutter/material.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  // GlobalKey untuk menangkap dan mengontrol validasi Form
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  // ===========================================================================
  // PENGATURAN TEMA & WARNA SOLID
  // ===========================================================================
  // Ubah nilai di bawah menjadi `true` jika ingin beralih ke background HITAM solid.
  // Default adalah `false` (Warna PUTIH solid).
  bool isDarkMode = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // Tahap 3: Logika Validasi & Feedback UI
  void _simpan() {
    // 1. Jalankan validasi pada TextFormField
    final isValid = _formKey.currentState?.validate() ?? false;

    // 2. Jika invalid (kosong / spasi saja), hentikan eksekusi (cegah simpan)
    if (!isValid) return;

    // 3. Jika valid, kirim data teks yang sudah di-trim kembali ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Palet warna solid
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color surfaceColor = isDarkMode ? const Color(0xFF1E2630) : const Color(0xFFF8FAFC);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF141B2B);
    final Color subtextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    const Color primaryColor = Color(0xFF1B5E3C); // Hijau khas UKM Hub Unand
    const Color errorColor = Color(0xFFDC2626); // Merah tegas untuk pesan validasi error

    // Gunakan Theme lokal agar tampilan terang (Putih) tidak ditimpa tema dark global
    return Theme(
      data: (isDarkMode ? ThemeData.dark() : ThemeData.light()).copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor, // Background SOLID PUTIH
        appBar: AppBar(
          title: Text(
            'Tulis Catatan',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textColor),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: borderColor.withValues(alpha: 0.5),
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              // Validasi otomatis dievaluasi ulang saat pengguna berinteraksi
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label & deskripsi form
                  Text(
                    'Catatan Aktivitas / UKM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tambahkan catatan atau pengingat personal mengenai kegiatan ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TextFormField dengan validasi error
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 5,
                    minLines: 3,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan Anda di sini...',
                      hintStyle: TextStyle(
                        color: subtextColor.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 1.8),
                      ),
                      // Tampilan border saat invalid
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: errorColor, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: errorColor, width: 2.0),
                      ),
                      // Pesan error berwarna merah di bawah field
                      errorStyle: const TextStyle(
                        color: errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Aturan validasi: tidak boleh kosong atau hanya berisi spasi
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Catatan tidak boleh kosong!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tombol Simpan
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Simpan'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
