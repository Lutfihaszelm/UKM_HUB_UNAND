# UKM Hub Unand

Aplikasi mobile Flutter untuk tugas besar mata kuliah Pemrograman Mobile (Kelompok 2). Mahasiswa melihat direktori UKM, feed postingan, berinteraksi (like, komentar, bagikan), dan mendaftar open recruitment. Pengelola UKM tidak memakai aplikasi ini; mereka memakai website admin terpisah.

Pekerjaan di repo ini difokuskan ke **Modul 3 (Open Recruitment)**, milik Lutfi. Modul 1 (Direktori dan Feed) dan Modul 2 (Interaksi Sosial) milik anggota lain: jangan diubah kecuali benar-benar perlu dan bilang dulu.

## Dokumen acuan
- `docs/api-contract.md`: ERD, DDL PostgreSQL, dan seluruh endpoint (29 mobile + 15 admin). **Acuan utama.**
- `docs/modul3.md`: detail Modul 3 (kolom, aturan bisnis, contoh request/response, antarmuka repository, tahapan kerja). Bila isinya bentrok dengan `api-contract.md`, pakai `api-contract.md`.
- Keduanya hasil ekspor dari dokumen di claude.ai. Bila kode perlu menyimpang dari kontrak, tanyakan dulu ke Lutfi; jangan ubah isi `docs/` sendiri.

## Stack
- Flutter, `flutter_riverpod`, `google_fonts`, `share_plus`, `file_picker`, `image_picker`, `shared_preferences`.
- Backend (dibuat partner): Express + PostgreSQL, REST di `/api/v1`, JWT Bearer. Belum ada saat ini, jadi aplikasi memakai data palsu. Tambahkan `dio` dan satu `ApiClient` hanya saat tahap integrasi backend.
- Tanpa Firebase (aturan proyek). Notifikasi memakai foreground service yang memanggil `GET /notifications?since=...` tiap 30 detik, ditampilkan lewat `flutter_local_notifications`.

## Struktur
- `lib/features/auth/`: splash dan login.
- `lib/features/jelajahi_ukm/`: Modul 1 (tab UKM).
- `lib/screens/home_screen.dart`, `post_detail_screen.dart`: Home, feed, detail postingan, komentar (Modul 2).
- `lib/features/oprec/`: **Modul 3.**
  - `data/oprec_repository.dart` (antarmuka), `fake_oprec_repository.dart`, `oprec_providers.dart` (`oprecRepositoryProvider`).
  - `models/oprec_post.dart`, `models/registration.dart`.
  - `presentation/screens/oprec_detail_screen.dart`, `oprec_form_screen.dart`.
- `lib/utils/validators.dart`: validator Nama, NIM, Motivasi (dipakai bersama).
- `lib/theme/`: warna utama `#2C6E49`.

## Keputusan yang sudah final (Modul 3)
- Satu postingan oprec = satu baris `posts` (`category = 'oprec'`) + satu baris `oprec_details` (`open_at`, `close_at`, `poster_url`).
- Status pendaftaran: `menunggu`, `seleksi`, `wawancara`, `diterima`, `ditolak`, `dibatalkan`. Perpindahan status hanya oleh admin; mahasiswa hanya bisa membatalkan.
- **Edit dan batal pendaftaran hanya saat status `menunggu`** (dan sebelum `close_at`). Batal tidak menghapus data: status jadi `dibatalkan`, riwayat tetap ada, dan mahasiswa boleh mendaftar lagi.
- Form pendaftaran mengirim: `full_name`, `nim`, `prodi`, `whatsapp`, `motivation`, dan satu berkas per slot yang diminta oprec (maks 2 MB per berkas). `prodi` dan `whatsapp` diisi di form dan disimpan per pendaftaran; **bukan** data akun user.
- Slot berkas dinamis per oprec (`RequiredFile`: label, jenis `image`/`pdf`/`any`, wajib atau opsional), ditentukan admin. Detail oprec juga punya daftar `requirements` dan `terms`. Ini keputusan 6 Nov 2026 dan sudah tercatat di kedua dokumen `docs/` (DDL, ERD Mermaid, endpoint); dokumen di claude.ai belum diperbarui.
- Pendaftaran akun baru lewat aplikasi (`POST /auth/register`), tanpa aktivasi admin.
- Penggantian data palsu ke server cukup dengan mengganti satu implementasi `OprecRepository` lewat `oprecRepositoryProvider`. Layar tidak boleh tahu bedanya.
- Pesan error 409 dari server sama dengan pesan di `FakeOprecRepository`, jadi tampilan error tidak berubah.

## Aturan proyek dari dosen
- Minimal 4 fungsi per modul, mencakup CRUD; data di server atau database lokal; tanpa Firebase untuk penyimpanan data.
- Tiap anggota wajib punya notifikasi di modulnya (Modul 3: perubahan status pendaftaran) dan memakai fitur perangkat (Modul 3: `file_picker` dan kamera lewat `image_picker`).

## Perintah
```
flutter pub get
flutter analyze      # harus bersih (No issues found)
flutter test         # saat ini 37 test, semuanya lulus
flutter run
```
Setelah mengubah kode: jalankan `flutter analyze` dan `flutter test`. Tambahkan test untuk model baru (pemetaan JSON, enum status) dan untuk layar yang ditambah.

## Konvensi
- Teks UI dalam Bahasa Indonesia. Warna dan gaya lewat `lib/theme/`, jangan hard-code warna baru.
- Error yang aman ditampilkan ke user dibungkus `RegistrationException(message)`.
- Jangan commit `build/` dan `.dart_tool/`.
- Kerjakan bertahap sesuai tabel "Rencana pengerjaan" di `docs/modul3.md`; tahap 1 sampai 3 (tanpa backend) dulu.

## Hal yang perlu diperhatikan saat nanti terhubung ke API
- `lib/screens/detail_screen.dart` masih memakai model lama `lib/models/ukm.dart` yang punya `category`; API tidak punya field itu. Ganti atau hapus barisnya.
- Tampilan komentar menampilkan program studi penulis (`dept`), tetapi API komentar tidak mengirim `prodi`. Hapus atau ganti baris itu.
- Emulator Android mengakses laptop lewat `10.0.2.2`, bukan `localhost`. Android 9 ke atas memblokir HTTP polos; aktifkan `usesCleartextTraffic` selama pengembangan.
- Unggah berkas: `MultipartFile.fromFile(file.path!)`. `PlatformFile.path` bernilai null di web, tetapi target proyek ini Android.
- Windows: bila Gradle error "different roots", letakkan proyek di drive yang sama dengan Pub cache.
