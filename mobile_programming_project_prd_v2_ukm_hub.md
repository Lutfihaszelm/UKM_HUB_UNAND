Mobile Programming — Project PRD
PROJECT PRD
Product Requirements Document
Project Name UKM Hub Unand — Feed Informasi & Open Recruitment UKM
Team [Nama 1 — NIM], [Nama 2 — NIM], [Nama 3 — NIM]
Course Mobile Programming
Version 2.0
Date 30 September 2026
Tujuan dokumen
PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk
dibutuhkan, dan kebutuhan utama produk. PRD tidak perlu menjelaskan detail implementasi kode.
1. Problem & Users
1.1 Problem Statement
Mahasiswa Universitas Andalas kesulitan mendapatkan informasi UKM (event, lomba, prestasi, open
recruitment, pengumuman) secara terpusat karena tersebar di berbagai akun media sosial. Mahasiswa
juga tidak punya cara mudah untuk berinteraksi (menyukai, mengomentari, membagikan) terhadap
kabar UKM yang mereka minati, maupun mendaftar open recruitment tanpa berpindah-pindah
platform.
1.2 Target Users
Satu jenis pengguna: Mahasiswa aktif Universitas Andalas yang ingin mengikuti kabar UKM dan
mendaftar open recruitment. Pengurus UKM bukan pengguna aplikasi mobile ini — mereka
mengelola profil UKM dan postingan lewat sistem backend terpisah (lihat Constraints).
1.3 User Needs / Pain Points
• Mahasiswa butuh satu feed terpusat untuk kabar seluruh UKM (event, lomba, prestasi, oprec,
pengumuman), tanpa follow banyak akun media sosial.
• Mahasiswa ingin bisa merespons kabar UKM (like, comment, share) seperti media sosial pada
umumnya.
• Mahasiswa butuh kejelasan status pendaftaran open recruitment secara realtime, tanpa bertanya
manual ke panitia.
• Mahasiswa ingin feed yang bisa dipersonalisasi sesuai UKM yang mereka ikuti.
1.4 Project Goal
Menyediakan aplikasi mobile berupa feed informasi UKM yang interaktif (like, comment, share)
sekaligus portal open recruitment, sehingga mahasiswa mendapat informasi UKM secara terpusat dan
proses pendaftaran UKM lebih transparan.
2. Product Requirements
2.1 Functional Requirements
FR-01: Mahasiswa dapat menjelajahi dan mencari daftar UKM.
FR-02: Mahasiswa dapat melihat detail profil UKM (nama, deskripsi, kontak, logo).
Mobile Programming — Project PRD
FR-03: Mahasiswa dapat mem-follow atau unfollow UKM tertentu.
FR-04: Mahasiswa dapat melihat feed postingan dari seluruh UKM maupun UKM yang diikuti.
FR-05: Mahasiswa dapat memfilter/mencari postingan berdasarkan kategori (event, lomba, prestasi,
oprec, pengumuman) atau UKM.
FR-06: Mahasiswa dapat melihat detail postingan beserta lampirannya (gambar/video/dokumen).
FR-07: Mahasiswa dapat menyukai (like) dan membatalkan suka pada postingan.
FR-08: Mahasiswa dapat menambah, mengedit, dan menghapus komentarnya sendiri pada postingan.
FR-09: Mahasiswa dapat membagikan (share) postingan ke aplikasi lain.
FR-10: Mahasiswa dapat mendaftar open recruitment (dari postingan berkategori oprec) dan
mengunggah berkas pendaftaran.
FR-11: Mahasiswa dapat mengedit atau membatalkan pendaftarannya sendiri sebelum periode oprec
ditutup.
FR-12: Mahasiswa dapat melihat status pendaftaran oprecnya sendiri secara realtime.
FR-13: Sistem mengirimkan notifikasi terkait postingan baru dari UKM yang diikuti, balasan
komentar, dan perubahan status pendaftaran.
FR-14: Sistem menampilkan pesan yang jelas ketika data (mis. feed/daftar UKM) tidak ditemukan
atau kosong.
2.2 Non-functional Requirements
NFR-01: Feed dan detail postingan dapat dimuat dalam ≤ 3 detik pada kondisi jaringan normal.
NFR-02: Antarmuka dapat digunakan dengan mudah oleh mahasiswa baru tanpa pelatihan khusus.
NFR-03: Aplikasi dapat berjalan pada perangkat Android versi 8 (Oreo) ke atas.
NFR-04: Berkas dan data pendaftaran oprec hanya dapat diakses oleh mahasiswa pendaftar yang
bersangkutan.
NFR-05: Aplikasi mobile tidak menyimpan data UKM/postingan secara mandiri; seluruh data UKM
dan postingan diambil dari REST API publik yang disediakan backend admin, tanpa Firebase.
NFR-06: Notifikasi terkirim ke pengguna dalam waktu wajar (≤ 1 menit) setelah kejadian terkait (post
baru, balasan komentar, status berubah).
2.3 Core Features
No. Core Feature Purpose / Value
1 Direktori & Feed UKM Mahasiswa mendapat informasi seluruh UKM dan kabar
terbarunya dalam satu tempat.
2 Interaksi Sosial pada Postingan Mahasiswa dapat merespons kabar UKM lewat like, comment,
dan share seperti media sosial.
3 Open Recruitment Mahasiswa dapat mendaftar UKM dan memantau status
seleksinya tanpa bertanya manual.
4 Follow & Feed Personal Mahasiswa dapat menyesuaikan feed dengan UKM yang mereka
minati.
5 Notifikasi Personal Mahasiswa mendapat info relevan (post baru, balasan komentar,
status oprec) tanpa cek manual.
2.4 User Flow
Mobile Programming — Project PRD
Open App → Login → Home (Feed Postingan dari UKM yang diikuti & seluruh UKM) → pilih salah
satu:
(a) Lihat Detail Postingan → Like / Comment / Share.
(b) Postingan berkategori Oprec → Isi Formulir & Upload Berkas → Submit Pendaftaran → Cek
Status Pendaftaran.
(c) Jelajahi Direktori UKM → Lihat Profil UKM → Follow.
2.5 Data Requirements
Data / Entity Key Information Purpose
User (Mahasiswa) Nama, NIM, email, no. HP Autentikasi dan identitas pengguna
aplikasi.
UKM (dari API publik) Nama, deskripsi, kontak, logo
Ditampilkan pada direktori dan profil
UKM; read-only bagi app
mahasiswa.
Post (dari API publik)
UKM terkait, kategori
(event/lomba/prestasi/oprec/pengumuman),
judul, isi, lampiran, tanggal
Sumber utama feed; read-only bagi
app mahasiswa.
Like Mahasiswa terkait, post terkait Menyimpan status suka mahasiswa
terhadap suatu postingan.
Comment Mahasiswa terkait, post terkait, isi, tanggal Menyimpan komentar mahasiswa
pada postingan.
Follow Mahasiswa terkait, UKM terkait Personalisasi feed dan notifikasi.
Pendaftaran Oprec Mahasiswa terkait, post oprec terkait,
berkas, status
Melacak proses pendaftaran open
recruitment mahasiswa.
2.6 Constraints & Assumptions
• Profil UKM dan postingan dikelola lewat backend admin UKM yang terpisah dari aplikasi
mobile; backend ini berperan sebagai alat bantu penyedia data (bukan bagian dari aplikasi yang
dinilai) dan diakses aplikasi mobile lewat REST API publik.
• Aplikasi mobile dikembangkan dengan Flutter; tidak menggunakan Firebase untuk penyimpanan
data, sesuai Aturan Project.
• Verifikasi hasil seleksi oprec (perubahan status pendaftar) dilakukan oleh admin UKM lewat
backend, kemudian tampil ke mahasiswa lewat API.
• Aplikasi mengasumsikan pengguna memiliki koneksi internet aktif; belum ada mode offline
penuh.
• Pengembangan dibatasi waktu satu semester perkuliahan Mobile Programming, dikerjakan oleh
tim 3 mahasiswa.
• Target platform awal adalah Android; dukungan iOS bersifat opsional.
2.7 Success Criteria
• Mahasiswa dapat menemukan dan berinteraksi (like/comment/share) dengan kabar UKM tanpa
harus follow banyak akun media sosial.
• Mahasiswa dapat mendaftar open recruitment dan memantau status tanpa bertanya manual ke
panitia.
• Mahasiswa menerima notifikasi relevan langsung di dalam aplikasi.
Mobile Programming — Project PRD
• Seluruh functional requirement inti (FR-01 s.d. FR-14) berhasil diimplementasikan dan diuji
sebelum demo akhir.
3. Scope
3.1 In Scope
• Direktori dan feed informasi UKM (multi-kategori: event, lomba, prestasi, oprec, pengumuman).
• Interaksi sosial pada postingan: like, comment, share.
• Follow UKM dan notifikasi personal.
• Open recruitment sisi mahasiswa: pendaftaran dan tracking status.
3.2 Out of Scope
• Aplikasi/antarmuka untuk admin UKM (dibangun terpisah sebagai backend, bukan bagian
aplikasi mobile yang dinilai).
• Manajemen anggota dan kas UKM.
• Presensi kehadiran berbasis QR code.
• Moderasi konten otomatis (mis. filter komentar kasar).
• Integrasi resmi dengan Sistem Informasi Akademik (SIA) Universitas Andalas.
4. AI Prompt Context
UKM Hub Unand adalah aplikasi mobile Flutter berupa feed informasi UKM yang interaktif (like,
comment, share) sekaligus portal open recruitment di Universitas Andalas. Aplikasi ini hanya
digunakan oleh mahasiswa; profil UKM dan postingan dikelola lewat backend admin terpisah dan
diakses aplikasi mobile lewat REST API publik (read-only dari sisi app).
Core features: Direktori & Feed UKM, Interaksi Sosial pada Postingan, Open Recruitment, Follow &
Feed Personal, dan Notifikasi Personal.
Batasan: aplikasi mobile dibangun dengan Flutter, tanpa Firebase untuk penyimpanan data; data
UKM/postingan berasal dari REST API publik backend admin (MySQL/PostgreSQL); dikerjakan tim
3 mahasiswa dalam satu semester.
Output yang diharapkan dari AI: bantuan merancang struktur data/konsumsi API sesuai functional
requirement di atas, potongan kode Flutter untuk komponen UI/logic (feed, like/comment, form
oprec), serta review UI/UX — bukan penulisan keseluruhan sistem secara otomatis.
PRD Checklist
☐ Problem statement jelas dan berfokus pada pengguna.
☐ Target users spesifik.
☐ Project goal menjawab masalah yang diidentifikasi.
☐ Core features berjumlah sekitar 4–6 dan relevan.
☐ User flow utama sudah dituliskan.
☐ Data utama sudah diidentifikasi.
☐ Constraints dan assumptions sudah dicatat.
☐ Success criteria dapat digunakan untuk menilai hasil project.
☐ In Scope dan Out of Scope sudah jelas.
Mobile Programming — Project PRD
☐ Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi.
☐ Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan,
dapat diukur.
☐ Functional requirements konsisten dengan core features.
☐ Non-functional requirements tidak ditulis sebagai fitur baru.