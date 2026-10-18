import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  // Wajib dipanggil sebelum kode async di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi StorageService agar shared_preferences siap dipakai
  await StorageService.instance.init();

  runApp(const ProviderScope(child: UkmHubApp()));
}
