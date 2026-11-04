import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/coming_soon_screen.dart';
import '../../application/notification_provider.dart';
import 'feed_screen.dart';
import 'jelajahi_ukm_screen.dart';
import 'notification_screen.dart';

/// Central Navigation Shell with BottomNavigationBar.
/// Hosts Modul 1 components:
/// - Tab 0: FeedScreen (FR-04, FR-05)
/// - Tab 1: JelajahiUkmScreen (FR-01)
/// - Tab 2: NotificationScreen (FR-13)
/// - Tab 3: Profil (ComingSoon)
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifCount = ref.watch(unreadNotificationCountProvider);

    final screens = [
      const FeedScreen(showBottomNav: false),
      const JelajahiUkmScreen(showBottomNav: false),
      const NotificationScreen(),
      const ComingSoonScreen(title: 'Profil Mahasiswa'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: const Color(0xFF2E7D6F),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps_rounded),
            label: 'UKM',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadNotifCount > 0,
              label: Text('$unreadNotifCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadNotifCount > 0,
              label: Text('$unreadNotifCount'),
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}