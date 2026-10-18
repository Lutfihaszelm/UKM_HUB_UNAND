import 'package:flutter/material.dart';
import 'models/oprec_post.dart';
import 'repositories/fake_oprec_repository.dart';
import 'repositories/oprec_repository.dart';
import 'screens/oprec_detail_screen.dart';

void main() {
  final OprecRepository repository = FakeOprecRepository();
  runApp(UkmHubApp(repository: repository));
}

class UkmHubApp extends StatelessWidget {
  final OprecRepository repository;
  const UkmHubApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final post = OprecPost(
      id: 'post-001',
      ukmName: 'AIESEC in UNAND',
      logoUKM: 'assets/images/Logo_AIESEC.png',
      posterAsset: 'assets/images/Poster_JA.jpg',
      title: 'Join AIESEC 2026',
      description: 'Ayo Join AIESEC.'
          'Syarat: mahasiswa aktif Unand, melampirkan CV.',
      closeDate: DateTime.now().add(const Duration(days: 7)),
    );

    return MaterialApp(
      title: 'UKM Hub Unand',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C6E49),
        ).copyWith(
          primary: const Color(0xFF2C6E49),
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFE8F0EB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: OprecDetailScreen(post: post, repository: repository),
    );
  }
}