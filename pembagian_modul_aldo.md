Mobile Programming — Pembagian Modul & Fungsionalitas
PEMBAGIAN MODUL & FUNGSIONALITAS
UKM Hub Unand
Project Name UKM Hub Unand — Feed Informasi & Open Recruitment UKM
Team Farrel Ghufran Rahman, Lutfi Hazel Muhammad, Aldo Septia Elvawan
Course Mobile Programming
Acuan PRD v2 (revisi pasca arahan dosen: satu audiens mahasiswa, backend
admin terpisah, feed bisa di-like/comment/share)
Date 12 Oktober 2026
Dokumen ini memetakan pembagian 3 modul aplikasi ke masing-masing anggota tim, beserta
fungsionalitas, operasi data (CRUD), notifikasi, dan fitur perangkat tiap modul — mengacu pada
Aturan Project (minimal 4 fungsionalitas per anggota, data dapat dikelola/CRUD, notifikasi per
modul, dan minimal satu fungsi memakai fitur perangkat).
Modul 1: Direktori & Feed UKM
Penanggung Jawab: Aldo
Mahasiswa menjelajahi UKM, mem-follow UKM yang diminati, dan melihat feed postingan (event,
lomba, prestasi, oprec, pengumuman) dari UKM yang diikuti maupun seluruh UKM.
No. Fungsionalitas Operasi Data FR Terkait
1 Jelajahi & cari UKM Read FR-01
2 Lihat detail profil UKM Read FR-02
3 Follow UKM Create FR-03
4 Unfollow UKM Delete FR-03
5 Feed postingan + filter kategori/UKM Read FR-04, FR-05
Notifikasi: pemberitahuan saat UKM yang difollow mem-posting sesuatu yang baru.
Data yang dikelola: relasi Follow (Mahasiswa–UKM).
Modul 2: Interaksi Sosial pada Postingan
Penanggung Jawab: Farrel
Mahasiswa dapat merespons postingan UKM lewat like, komentar, dan share — menjadikan feed
interaktif seperti media sosial.
No. Fungsionalitas Operasi Data FR Terkait
1 Like postingan Create FR-07
2 Unlike / batalkan like Delete FR-07
3 Tambah & edit komentar sendiri Create / Update FR-08
4 Hapus komentar sendiri Delete FR-08
Mobile Programming — Pembagian Modul & Fungsionalitas
5 Share postingan ke aplikasi lain — FR-09
Notifikasi: pemberitahuan saat komentar sendiri mendapat balasan.
Data yang dikelola: Like (Mahasiswa–Post), Comment (CRUD milik sendiri).
Modul 3: Open Recruitment
Penanggung Jawab: Lutfi Hazel Muhammad
Mahasiswa mendaftar open recruitment dari postingan berkategori oprec, mengelola pendaftarannya
sendiri, dan memantau status seleksi secara realtime.
No. Fungsionalitas Operasi Data FR Terkait
1 Daftar oprec + upload berkas pendaftaran Create FR-10
2 Lihat status pendaftaran (realtime) Read FR-12
3 Edit pendaftaran sebelum periode ditutup Update FR-11
4 Batalkan pendaftaran Delete FR-11
Notifikasi: pemberitahuan saat status pendaftaran berubah (terkirim/seleksi/wawancara/hasil).
Fitur perangkat: kamera/file picker untuk upload berkas pendaftaran (foto/PDF) — memenuhi syarat
minimal 1 fitur perangkat di aplikasi.
Data yang dikelola: Pendaftaran Oprec (CRUD penuh milik mahasiswa bersangkutan).
Catatan Kepatuhan terhadap Aturan Project
• Setiap modul memiliki ≥4 fungsionalitas berbeda (3a) — Modul 1 & 2
masing-masing 5, Modul 3 tepat 4.
• Setiap modul memiliki data yang dapat dikelola dengan CRUD (3b): Follow, Like/Comment, dan
Pendaftaran Oprec.
• Setiap modul memiliki notifikasi sendiri yang relevan dengan fungsinya (3f).
• Minimal satu fungsi memakai fitur perangkat (3g) — dipenuhi lewat upload berkas (kamera/file
picker) di Modul 3.
• Data UKM dan Post bersifat read-only di aplikasi mobile (diambil dari REST API publik
backend admin), sehingga tidak dihitung sebagai CRUD modul mahasiswa — sesuai arahan
dosen terbaru.