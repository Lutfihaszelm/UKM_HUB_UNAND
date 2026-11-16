import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_repository.dart';
import '../data/post_repository.dart';
import '../data/ukm_repository.dart';

/// Titik ganti tunggal saat backend Modul 1 siap.
final ukmRepositoryProvider = Provider<UkmRepository>(
  (ref) => const FakeUkmRepository(),
);

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => const FakePostRepository(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FakeNotificationRepository(),
);
