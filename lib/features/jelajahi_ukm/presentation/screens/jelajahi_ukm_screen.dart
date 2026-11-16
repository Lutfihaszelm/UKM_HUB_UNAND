import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../services/storage_service.dart';
import '../../application/jelajahi_ukm_provider.dart';
import '../../application/notification_provider.dart';
import '../../models/ukm.dart';
import '../widgets/ukm_card.dart';

/// FR-01: Jelajahi & cari UKM.
///
/// Tampilan mengikuti desain Figma terbaru: hero hijau dengan palm, pill
/// profil, kartu UKM ringkas, dan search bar di bagian bawah.
class JelajahiUkmScreen extends ConsumerStatefulWidget {
  const JelajahiUkmScreen({super.key});

  @override
  ConsumerState<JelajahiUkmScreen> createState() => _JelajahiUkmScreenState();
}

class _JelajahiUkmScreenState extends ConsumerState<JelajahiUkmScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredUkmListProvider);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(ukmCategoryFilterProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final displayName = _displayName();

    return Theme(
      // Semua teks di layar ini (termasuk bottom sheet) memakai Plus Jakarta
      // Sans agar konsisten dengan desain Figma.
      data: _jakartaTheme(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F2),
        body: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: _HeroBackground()),
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          _HeroHeader(
                            name: displayName,
                            initial: _avatarInitial(displayName),
                            onProfileTap: () => _showQuickMenu(unreadCount),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              color: const Color(0xFF2C6E49),
                              onRefresh: () async {
                                ref.invalidate(ukmListProvider);
                                await ref.read(ukmListProvider.future);
                              },
                              child: _buildList(context, filteredList),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomSearchBar(
              controller: _searchController,
              query: query,
              hasActiveFilter: category != null,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              onClear: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).clear();
              },
              onFilterTap: _showFilterSheet,
            ),
          ],
        ),
      ),
    );
  }

  /// Tema turunan yang seluruh textTheme-nya memakai Plus Jakarta Sans.
  static ThemeData _jakartaTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
    );
  }

  Widget _buildList(BuildContext context, AsyncValue<List<Ukm>> asyncList) {
    final items = asyncList.value;

    if (items == null) {
      if (asyncList.hasError) {
        return _StateScrollView(
          child: _CenteredState(
            icon: Icons.cloud_off_rounded,
            title: 'Gagal memuat daftar UKM',
            message: 'Periksa koneksi lalu coba lagi.',
            actionLabel: 'Coba Lagi',
            onAction: () => ref.invalidate(ukmListProvider),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const _StateScrollView(
        child: _CenteredState(
          icon: Icons.search_off_rounded,
          title: 'UKM tidak ditemukan',
          message: 'Coba kata kunci lain.',
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ukm = items[index];
              return UkmCard(
                ukm: ukm,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.ukmDetail,
                  arguments: ukm,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _displayName() {
    try {
      final name = StorageService.instance.username.trim();
      if (name.isNotEmpty && name != 'Pengguna') return name;
    } catch (_) {
      // StorageService belum diinisialisasi (mis. widget test).
    }
    return 'Londri';
  }

  String _avatarInitial(String name) {
    try {
      final initial = StorageService.instance.avatarInitial.trim();
      if (initial.isNotEmpty && initial != 'U') return initial;
    } catch (_) {
      // StorageService belum diinisialisasi (mis. widget test).
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'L';
  }

  Future<void> _showQuickMenu(int unreadCount) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Theme(
          data: _jakartaTheme(sheetContext),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dynamic_feed_rounded,
                    color: Color(0xFF2C6E49),
                  ),
                  title: const Text('Feed UKM'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, AppRoutes.feed);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF2C6E49),
                  ),
                  title: const Text('Notifikasi'),
                  trailing: unreadCount > 0
                      ? _UnreadBadge(count: unreadCount)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterSheet() async {
    final categories = ref.read(ukmCategoriesProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final selected = ref.read(ukmCategoryFilterProvider);

        return Theme(
          data: _jakartaTheme(sheetContext),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filter UKM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF122019),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref.read(ukmCategoryFilterProvider.notifier).clear();
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: selected == null,
                        onTap: () {
                          ref.read(ukmCategoryFilterProvider.notifier).clear();
                          Navigator.pop(sheetContext);
                        },
                      ),
                      for (final category in categories)
                        _FilterChip(
                          label: category,
                          selected: selected == category,
                          onTap: () {
                            ref
                                .read(ukmCategoryFilterProvider.notifier)
                                .setCategory(category);
                            Navigator.pop(sheetContext);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF245C3D), Color(0xFF2C6E49), Color(0xFF4F8867)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -55,
            right: -35,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.park_rounded,
                size: 210,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -70,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.eco_rounded,
                size: 180,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 42,
            child: Text(
              'UKM HUB',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.name,
    required this.initial,
    required this.onProfileTap,
  });

  final String name;
  final String initial;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jelajahi UKM',
                  style: TextStyle(
                    fontSize: 29,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cari Passion Anda Disini',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.2,
                    color: Color(0xFFD5E5DA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ProfilePill(name: name, initial: initial, onTap: onProfileTap),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({
    required this.name,
    required this.initial,
    required this.onTap,
  });

  final String name;
  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B0F0D),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 5, 5, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 88),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C6E49),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSearchBar extends StatelessWidget {
  const _BottomSearchBar({
    required this.controller,
    required this.query,
    required this.hasActiveFilter,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String query;
  final bool hasActiveFilter;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7F2),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF122019),
                ),
                decoration: InputDecoration(
                  hintText: 'Jelajahi UKM baru',
                  hintStyle: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF9AA7A0),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: Color(0xFF5B6B61),
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: Color(0xFF5B6B61),
                          ),
                        ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _FilterButton(active: hasActiveFilter, onTap: onFilterTap),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2C6E49),
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: const Color(0x552C6E49),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.tune_rounded, size: 21, color: Colors.white),
              if (active)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE047),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2C6E49) : const Color(0xFFF1F5F2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Scrollable pembungkus state kosong/error agar RefreshIndicator tetap bisa
/// menarik dan kontennya mengisi area yang tersedia.
class _StateScrollView extends StatelessWidget {
  const _StateScrollView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3EE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: const Color(0xFF2C6E49)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF122019),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF6B7A71),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
