import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukm_hub/app.dart';
import 'package:ukm_hub/features/auth/data/dummy_account.dart';
import 'package:ukm_hub/screens/home_screen.dart';

void main() {
  testWidgets('App starts on Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    expect(find.text('Masuk ke UKM Hub'), findsOneWidget);
    expect(find.text('Email Mahasiswa / NIM'), findsOneWidget);
  });

  testWidgets('Login with invalid input shows validation error messages',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    // Submit kosong -> field wajib diisi.
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    // Format email salah.
    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.pump();
    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);

    // Format sudah benar tapi akun tidak cocok -> error dari server/akun.
    await tester.enterText(find.byType(TextFormField).first, 'salah@student.unand.ac.id');
    await tester.enterText(find.byType(TextFormField).last, 'passwordsalah');
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Email/NIM atau kata sandi salah.'), findsOneWidget);
    expect(find.text('Masuk ke UKM Hub'), findsOneWidget); // tetap di Login
  });

  testWidgets('Valid login navigates to Home and cannot pop back to Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    await tester.enterText(find.byType(TextFormField).first, DummyAccount.email);
    await tester.enterText(find.byType(TextFormField).last, DummyAccount.password);
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget); // AppBar title
    expect(find.text('Masuk ke UKM Hub'), findsNothing);

    final context = tester.element(find.text('Home'));
    expect(Navigator.canPop(context), isFalse);
  });

  testWidgets(
      'Different posts open Detail with matching data, and back returns to Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    await tester.enterText(find.byType(TextFormField).first, DummyAccount.email);
    await tester.enterText(find.byType(TextFormField).last, DummyAccount.password);
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle(); // login + Home selesai memuat data

    expect(find.text('Open Recruitment UKM Robotika 2026'), findsOneWidget);

    await tester.tap(find.text('Open Recruitment UKM Robotika 2026'));
    await tester.pumpAndSettle();

    // Judul post tampil di AppBar sekaligus di body.
    expect(find.text('Open Recruitment UKM Robotika 2026'), findsNWidgets(2));
    expect(find.textContaining('UKM Robotika membuka pendaftaran'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Juara 1 Lomba Debat Bahasa Inggris Nasional'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('National University Debating Championship'),
      findsOneWidget,
    );
  });

  testWidgets('Writing a note in the form returns it to Detail screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    await tester.enterText(find.byType(TextFormField).first, DummyAccount.email);
    await tester.enterText(find.byType(TextFormField).last, DummyAccount.password);
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Recruitment UKM Robotika 2026'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Tulis Catatan'), findsWidgets); // AppBar + tombol sebelumnya

    // Coba simpan catatan kosong -> validator harus menahan submit.
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    // Coba simpan catatan yang terlalu pendek.
    await tester.enterText(find.byType(TextFormField), 'abcd');
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Catatan uji coba');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan: Catatan uji coba'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget); // SnackBar
  });

  testWidgets('Home shows loading first, then the list of posts',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Sebelum data selesai dimuat -> tampil loading.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat data...'), findsOneWidget);
    expect(find.text('Open Recruitment UKM Robotika 2026'), findsNothing);

    await tester.pumpAndSettle();

    // Setelah selesai -> daftar post tampil, loading hilang.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Open Recruitment UKM Robotika 2026'), findsOneWidget);
  });

  testWidgets('Home with simulateError shows ErrorView and Coba Lagi button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen(simulateError: true)));
    await tester.pumpAndSettle();

    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
    expect(find.text('Gagal memuat data. Periksa koneksi internet.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Coba Lagi'), findsOneWidget);

    // Tap "Coba Lagi" -> tetap error karena simulateError masih true.
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
  });

  testWidgets('Navigating to an unregistered route shows the 404 page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkmHubApp()));

    await tester.enterText(find.byType(TextFormField).first, DummyAccount.email);
    await tester.enterText(find.byType(TextFormField).last, DummyAccount.password);
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Home'));
    Navigator.of(context).pushNamed('/tidak-terdaftar');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Halaman Tidak Ditemukan'), findsOneWidget);
  });
}
