# Integrasi 3 Modul – UKM Hub Unand (18 Okt 2026)

Basis: branch Modul 2 (Farrel). Modul 1 (Aldo) dan Modul 3 (Lutfi) dipasang ke dalamnya.

## Struktur
- `lib/features/auth/` – Splash & Login (fondasi)
- `lib/screens/home_screen.dart` – Home + bottom navigation (tab Home / UKM / Aktivitas / Profil)
- `lib/screens/post_detail_screen.dart` – Modul 2: like, komentar CRUD, balas, laporkan, share
- `lib/features/jelajahi_ukm/` – Modul 1: Jelajahi & cari UKM (tab **UKM**)
- `lib/features/oprec/` – Modul 3: Detail oprec, form + upload berkas (kartu **Open Recruitment** di Home)
- `lib/widgets/app_card.dart`, `lib/widgets/ukm_logo.dart` – widget bersama hasil refactor

## Perubahan saat integrasi
1. Tab bottom navigation sekarang benar-benar berpindah isi (sebelumnya hanya ganti index).
2. `JelajahiUkmScreen` tidak lagi punya bottom nav sendiri (dipakai di dalam Home).
3. Model `Ukm` milik Modul 1 dipindah ke `features/jelajahi_ukm/models/` agar tidak bentrok dengan `models/ukm.dart` milik Modul 2.
4. Tombol "Lihat Detail" di section Open Recruitment Home membuka `AppRoutes.oprecDetail`.
5. Repository oprec disediakan lewat Riverpod (`oprecRepositoryProvider`) supaya satu instance untuk seluruh app.
6. Warna utama disamakan ke `#2C6E49` (sebelumnya `#1B5E3C` dan `#2E7D6F`).
7. Validator Nama/NIM/Motivasi digabung ke `lib/utils/validators.dart`.
8. Konten dummy postingan BEM & AIESEC diganti teks netral untuk demo.

## Cara menjalankan
```
flutter pub get
flutter run
flutter test   # 16 test (Modul 1 search, splash, integrasi Home->UKM, Home->Oprec->Form, validator)
```
`flutter analyze`: No issues found.
