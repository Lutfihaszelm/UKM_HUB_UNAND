import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/routing/app_routes.dart';
import '../services/storage_service.dart';

/// Halaman Profile (Profile Screen) untuk aplikasi "UKM Hub Unand".
///
/// Memiliki desain Glassmorphism autentik (ala-ala glass) persis sesuai mockup:
/// - Foto pengguna asli dengan kartu kaca buram (frosted glass) di atasnya.
/// - Efek glassmorphic menggunakan BackdropFilter blur, border putih bercahaya, dan gradasi transparan.
/// - Bottom sheet hijau (#2C6E49) yang terletak di bawah kartu kaca.
/// - Parameter dinamis [isCurrentUser] untuk membedakan Profil Pribadi & Profil Orang Lain.
/// - Fitur fungsional: Ganti foto, Edit Profil lengkap (Nama, Tanggal/Tempat Lahir, Alamat, Bio).
class ProfileScreen extends StatefulWidget {
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    this.isCurrentUser = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Warna Utama & Tema
  static const Color primaryGreen = Color(0xFF2C6E49);
  static const Color ukmBlueColor = Color(0xFF027FF3);
  static const Color followingContainerColor = Color(0xFF387B55);

  // StorageService
  final _storage = StorageService.instance;

  // Data Profil Pengguna (Stateful agar bisa diedit langsung secara reaktif)
  late String _nama;
  late String _tanggalLahir;
  late String _tempatLahir;
  late String _alamat;
  late String _bio;
  late String _profileImagePath;

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final displayName = _storage.displayName;
    // Kapitalkan huruf pertama untuk tampilan
    final capitalizedName = displayName.isNotEmpty
        ? displayName[0].toUpperCase() + displayName.substring(1)
        : 'Pengguna';

    _nama = widget.isCurrentUser ? capitalizedName : 'Lutfi Hazel';
    _tanggalLahir = _storage.profileBirthDate;
    _tempatLahir = _storage.profileBirthPlace;
    _alamat = _storage.profileAddress;
    _bio = widget.isCurrentUser
        ? _storage.profileBio
        : 'Sebenarnya Ku ingin mengungkapkan rasa tapi mengapa';
    _profileImagePath = _storage.profileImagePath;
  }

  // ── Pilih Foto Profil dari Galeri atau Kamera ──────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file != null && mounted) {
        await _storage.setProfileImagePath(file.path);
        setState(() {
          _profileImagePath = file.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui!'),
              backgroundColor: primaryGreen,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat foto: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  // ── Tampilkan bottom sheet pilihan sumber foto ─────────────────────────────
  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildPhotoSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: primaryGreen, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // ── Membangun widget foto profil (asset atau file) ─────────────────────────
  Widget _buildProfilePhoto(double height) {
    final isAsset = _profileImagePath.startsWith('assets/');

    Widget photoWidget;
    if (isAsset) {
      photoWidget = Image.asset(
        _profileImagePath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => _buildInitialsPhoto(),
      );
    } else {
      photoWidget = Image.file(
        File(_profileImagePath),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => _buildInitialsPhoto(),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: photoWidget,
        ),
        // Tombol kamera overlay (hanya untuk profil pribadi)
        if (widget.isCurrentUser)
          Positioned(
            bottom: 12,
            right: 16,
            child: GestureDetector(
              onTap: _showPhotoSourcePicker,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isPickingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsPhoto() {
    final initial = _storage.displayName.isNotEmpty
        ? _storage.displayName[0].toUpperCase()
        : 'U';
    return Container(
      color: const Color(0xFF1B5E3C),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      // ─── AppBar Transparan dengan Tombol Kembali Hitam Tebal ───
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      // ─── Body: Stack (Foto Wajah + Green Sheet + Floating Glass Card) ───
      body: Stack(
        children: [
          // 1. Layer Paling Bawah: Foto Wajah (dari asset atau file)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.68,
            child: _buildProfilePhoto(screenHeight * 0.68),
          ),

          // 2. Layer Tengah: Bottom Sheet Hijau (#2C6E49) di Bagian Bawah
          Positioned(
            top: screenHeight * 0.64,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
          ),

          // 3. Layer Atas: Konten Scrollable (Kartu Kaca Glassmorphic + Bio)
          SafeArea(
            child: Column(
              children: [
                // Ruang kosong untuk memperlihatkan wajah di bagian atas
                SizedBox(height: screenHeight * 0.36),

                // Area Konten Scrollable (Bebas RenderFlex Overflow)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Kartu Glassmorphic (Ala-ala Glass dengan BackdropFilter Blur)
                        _buildGlassmorphismCard(),

                        const SizedBox(height: 14),

                        // Area Bio Dinamis
                        if (widget.isCurrentUser) ...[
                          // Profil Pribadi: Kotak "Tambahkan Bio" (Bisa diklik untuk input bio)
                          _buildPersonalBioBox(),
                        ] else ...[
                          // Profil Orang Lain: Kotak Bio Statis
                          _buildOtherBioBox(),

                          const SizedBox(height: 14),

                          // Section "Mengikuti" + 4 Ikon UKM
                          _buildFollowingSection(),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // ─── Bottom Navigation Bar dengan Indikator Aktif pada Profil ───
      bottomNavigationBar: _ProfileBottomNavBar(context: context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Kartu Glassmorphic Autentik (Ala-ala Glass dengan Frosted Blur)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGlassmorphismCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            18,
            16,
            widget.isCurrentUser ? 16 : 20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1B3B8B).withValues(alpha: 0.50),
                const Color(0xFFBE123C).withValues(alpha: 0.45),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Teks Nama
              if (widget.isCurrentUser)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Halo ',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(
                        text: '$_nama,',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  _nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),

              const SizedBox(height: 6),

              // Tanggal & Tempat Lahir / Alamat
              Text(
                '$_tanggalLahir\n$_alamat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),

              // Tombol "Edit Profile" (Hanya pada Profil Pribadi)
              if (widget.isCurrentUser) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Kotak Bio untuk Profil Pribadi (Bisa Diklik untuk Tambah / Edit Bio)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPersonalBioBox() {
    final hasBio = _bio.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showEditBioModal,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hasBio ? _bio : 'Tambahkan Bio',
                  style: TextStyle(
                    color: hasBio ? const Color(0xFF2C3E50) : const Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: hasBio ? FontWeight.w500 : FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF8E8E93),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Kotak Bio untuk Profil Orang Lain
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildOtherBioBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _bio,
        style: const TextStyle(
          color: Color(0xFF636366),
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Section "Mengikuti" + 4 Ikon UKM (Khusus Profil Orang Lain)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildFollowingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mengikuti',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: followingContainerColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _buildUkmBox(
                isBlue: true,
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              _buildUkmBox(
                isBlue: true,
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              _buildUkmBox(
                isBlue: true,
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              _buildUkmBox(
                isBlue: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset(
                    'assets/images/firetech neo.jpeg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'TELEMETRI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUkmBox({required bool isBlue, required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isBlue ? ukmBlueColor : Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. Fungsi Modal: Edit Profile Lengkap (Nama, TTL, Alamat, Bio)
  // ─────────────────────────────────────────────────────────────────────────────
  void _showEditProfileModal() {
    final namaController = TextEditingController(text: _nama);
    final tempatLahirController = TextEditingController(text: _tempatLahir);
    final tanggalLahirController = TextEditingController(text: _tanggalLahir);
    final alamatController = TextEditingController(text: _alamat);
    final bioController = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Field 1: Nama
                _buildFormField(
                  label: 'Nama Lengkap / Panggilan',
                  controller: namaController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),

                // Field 2: Tempat Lahir
                _buildFormField(
                  label: 'Tempat Lahir',
                  controller: tempatLahirController,
                  icon: Icons.location_city_rounded,
                ),
                const SizedBox(height: 12),

                // Field 3: Tanggal Lahir
                _buildFormField(
                  label: 'Tanggal Lahir',
                  controller: tanggalLahirController,
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 12),

                // Field 4: Alamat / Domisili
                _buildFormField(
                  label: 'Alamat / Domisili',
                  controller: alamatController,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 12),

                // Field 5: Bio
                _buildFormField(
                  label: 'Bio',
                  controller: bioController,
                  icon: Icons.edit_note_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newNama = namaController.text.trim().isEmpty
                          ? _nama
                          : namaController.text.trim();
                      final newTempatLahir = tempatLahirController.text.trim();
                      final newTanggalLahir = tanggalLahirController.text.trim();
                      final newAlamat = alamatController.text.trim();
                      final newBio = bioController.text.trim();

                      // Simpan ke StorageService
                      await Future.wait([
                        if (newTempatLahir.isNotEmpty)
                          _storage.setProfileBirthPlace(newTempatLahir),
                        if (newTanggalLahir.isNotEmpty)
                          _storage.setProfileBirthDate(newTanggalLahir),
                        if (newAlamat.isNotEmpty)
                          _storage.setProfileAddress(newAlamat),
                        _storage.setProfileBio(newBio),
                      ]);

                      setState(() {
                        _nama = newNama;
                        _tempatLahir = newTempatLahir.isNotEmpty ? newTempatLahir : _tempatLahir;
                        _tanggalLahir = newTanggalLahir.isNotEmpty ? newTanggalLahir : _tanggalLahir;
                        _alamat = newAlamat.isNotEmpty ? newAlamat : _alamat;
                        _bio = newBio;
                      });

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil diperbarui!'),
                            backgroundColor: primaryGreen,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. Fungsi Modal: Tambah / Edit Bio Langsung
  // ─────────────────────────────────────────────────────────────────────────────
  void _showEditBioModal() {
    final bioController = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bio Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 3,
                maxLength: 120,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tuliskan bio singkat tentang dirimu...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    final newBio = bioController.text.trim();
                    await _storage.setProfileBio(newBio);
                    setState(() {
                      _bio = newBio;
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bio berhasil diperbarui!'),
                          backgroundColor: primaryGreen,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Bio',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-Widget: Bottom Navigation Bar dengan Indikator Aktif pada Profil
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileBottomNavBar extends StatelessWidget {
  final BuildContext context;

  const _ProfileBottomNavBar({required this.context});

  static const Color primaryGreen = Color(0xFF2C6E49);
  static const Color navPillColor = Color(0xFF427C5C);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: primaryGreen,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Garis Arch / Lengkungan Halus di Atas Bar Hijau
          Positioned(
            top: -12,
            left: 12,
            right: 12,
            bottom: bottomPadding,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC7D7CD),
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),

          // Bar Utama Hijau #2C6E49
          Container(
            padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding * 0.4 : 0),
            height: 64 + (bottomPadding > 0 ? bottomPadding * 0.4 : 0),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                _buildNavItem(
                  icon: Icons.home_outlined,
                  isActive: false,
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                ),

                // 2. UKM
                _buildNavItem(
                  icon: Icons.apartment_outlined,
                  isActive: false,
                  onTap: () {},
                ),

                // 3. Aktivitas
                _buildNavItem(
                  icon: Icons.assignment_outlined,
                  isActive: false,
                  onTap: () {},
                ),

                // 4. Profil (Aktif dengan Garis Pill)
                _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  isActive: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: navPillColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
    );
  }
}
