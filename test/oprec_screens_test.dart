import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/features/oprec/data/fake_oprec_repository.dart';
import 'package:ukm_hub/features/oprec/models/oprec_post.dart';
import 'package:ukm_hub/features/oprec/presentation/oprec_theme.dart';
import 'package:ukm_hub/features/oprec/presentation/screens/oprec_detail_screen.dart';
import 'package:ukm_hub/features/oprec/presentation/screens/oprec_form_screen.dart';

/// Font test (Ahem) jauh lebih lebar dari font asli, jadi peringatan overflow
/// layout diabaikan; yang diuji adalah isi dan perilaku layar.
void _ignoreOverflow() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
}

final _post = OprecPost(
  id: 'oprec-mapala',
  ukmName: 'MAPALA',
  logoUKM: null,
  title: 'Oprec MAPALA',
  description: 'Wadah pemuda pecinta alam.',
  closeDate: DateTime(2030, 8, 17),
  requirements: const [
    'Mahasiswa Aktif Universitas Andalas',
    'Masih hidup dan berani',
    'IPK > 3.00',
    'Sehat jasmani',
  ],
  requiredFiles: const [
    RequiredFile(id: 'foto', label: 'Pas Foto', accept: FileAccept.image),
    RequiredFile(id: 'ktm', label: 'KTM', accept: FileAccept.image),
    RequiredFile(
      id: 'extra',
      label: 'Dokumen Tambahan',
      accept: FileAccept.pdf,
      isRequired: false,
    ),
  ],
  terms: const ['Wajib hadir tepat waktu.'],
);

Widget _wrap(Widget child) =>
    MaterialApp(theme: buildOprecTheme(), home: child);

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
  });

  testWidgets('Detail oprec menampilkan kartu syarat, berkas, dan S&K',
      (tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrap(OprecDetailScreen(
      post: _post,
      repository: FakeOprecRepository(latency: Duration.zero),
    )));

    // Sheet ditarik ke atas supaya semua kartu terlihat.
    await tester.drag(find.text('MAPALA'), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Ditutup : 17 Agustus 2030'), findsOneWidget);
    expect(find.text('Syarat Pendaftaran'), findsOneWidget);
    expect(find.text('DAFTAR SEKARANG'), findsOneWidget);

    // Syarat ke-4 tersembunyi sampai "lihat selengkapnya" ditekan.
    expect(find.text('Sehat jasmani'), findsNothing);
    await tester.tap(find.text('lihat selengkapnya'));
    await tester.pump();
    expect(find.text('Sehat jasmani'), findsOneWidget);

    await tester.scrollUntilVisible(
        find.text('Syarat dan Ketentuan Berlaku'), 200);
    expect(find.text('Berkas yang diunggah'), findsOneWidget);
    expect(find.text('Dokumen Tambahan (opsional)'), findsOneWidget);
  });

  testWidgets('Form menampilkan satu slot per berkas yang diminta oprec',
      (tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrap(OprecFormScreen(
      post: _post,
      repository: FakeOprecRepository(latency: Duration.zero),
    )));

    expect(find.text('Formulir Pendaftaran'), findsOneWidget);
    for (final label in ['Nama', 'NIM', 'Program Studi', 'No.WhatsApp']) {
      expect(find.text(label), findsOneWidget);
    }

    // Isi semua data teks (field ada di atas, sebelum layar di-scroll).
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nama Mahasiswa');
    await tester.enterText(fields.at(1), '2411520000');
    await tester.enterText(fields.at(2), 'Sistem Informasi');
    await tester.enterText(fields.at(3), '081234567890');
    await tester.enterText(
        fields.at(4), 'Saya ingin belajar dan berkontribusi di UKM ini.');
    await tester.pump();

    // Scrollable pertama = ListView form (field motivasi punya scrollable sendiri).
    await tester.scrollUntilVisible(find.text('KONFIRMASI'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Pas Foto'), findsOneWidget);
    expect(find.text('KTM'), findsOneWidget);
    expect(find.text('Dokumen Tambahan (opsional)'), findsOneWidget);
    expect(find.text('Pilih File'), findsNWidgets(3));
    // Kamera hanya untuk slot gambar (Pas Foto dan KTM), bukan PDF.
    expect(find.byTooltip('Ambil foto'), findsNWidgets(2));

    // Data teks lengkap tetapi berkas wajib belum ada: tombol tetap mati.
    final button = tester.widget<FilledButton>(
        find.ancestor(of: find.text('KONFIRMASI'), matching: find.byType(FilledButton)));
    expect(button.onPressed, isNull);
  });
}
