import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/coming_soon_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'jelajahi_ukm_screen.dart';

/// Central Navigation Shell with BottomNavigationBar.
/// Hosts the main app tabs:
/// - Tab 0: HomeScreen (Home / Beranda)
/// - Tab 1: JelajahiUkmScreen (FR-01)
/// - Tab 2: Slot Open Recruitment (Modul 3, dipertahankan visual, dinonaktifkan di branch Modul 1)
/// - Tab 3: Profil (ComingSoon)
///
/// Catatan Navigasi:
/// Sesuai ketentuan, halaman Notifikasi (FR-13) hanya dapat diakses
/// melalui ikon lonceng pada header Home Screen, bukan melalui bottom navigation.
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
    // Cegah tab 2 (menu nonaktif) sebagai initial index
    _currentIndex = widget.initialIndex == 2 ? 0 : widget.initialIndex;
  }

  void _onTabChanged(int index) {
    if (index == 2) return; // Nonaktifkan interaksi/navigasi menu ketiga pada branch Modul 1
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _onTabChanged),
      const JelajahiUkmScreen(showBottomNav: false),
      const SizedBox.shrink(), // Slot Open Recruitment (Modul 3) - dinonaktifkan sementara di branch Modul 1
      const ComingSoonScreen(title: 'Profil Mahasiswa'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF266E4E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tab 0: Home / Beranda
                _BottomNavItem(
                  icon: _currentIndex == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                  label: 'Beranda',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabChanged(0),
                ),

                // Tab 1: UKM / Direktori
                _BottomNavItem(
                  icon: Icons.apartment_rounded,
                  label: 'UKM',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabChanged(1),
                ),

                // Tab 2: Slot Open Recruitment (Modul 3)
                // Dipertahankan secara visual sesuai desain awal, tanpa badge notifikasi dan interaksi dinonaktifkan
                _BottomNavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Open Recruitment',
                  badgeCount: 0,
                  isSelected: false,
                  onTap: () {}, // Dinonaktifkan sementara pada branch Modul 1
                ),

                // Tab 3: Profil
                _BottomNavItem(
                  icon: _currentIndex == 3
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: 'Profil',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabChanged(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: 26,
      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text('$badgeCount'),
        child: iconWidget,
      );
    }

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 20 : 16,
              vertical: 8,
            ),
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  )
                : const BoxDecoration(),
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
