import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_routes.dart';
import '../../application/feed_provider.dart';
import '../../application/jelajahi_ukm_provider.dart';
import '../../application/follow_provider.dart';
import '../../models/post.dart';
import '../../models/ukm.dart';
import '../widgets/post_card.dart';

/// FR-04 & FR-05: Feed informasi terkini dan filter/pencarian.
///
/// Feed ini adalah milik Modul 1 dan tidak mengubah Home. Entry point tersedia
/// dari header halaman Jelajahi UKM.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(feedPostsProvider);
    final posts = postsAsync.value;
    final ukms = ref.watch(ukmListProvider).value ?? const <Ukm>[];
    final hasFilter = ref.watch(hasActiveFeedFilterProvider);
    final scope = ref.watch(feedScopeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedUkm = ref.watch(selectedFeedUkmProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F2),
        body: RefreshIndicator(
          color: const Color(0xFF2C6E49),
          onRefresh: () async {
            ref.invalidate(feedPostsProvider);
            await ref.read(feedPostsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _FeedHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FilterPanel(
                  searchController: _searchController,
                  scope: scope,
                  selectedCategory: selectedCategory,
                  selectedUkm: selectedUkm,
                  ukms: ukms,
                  hasFilter: hasFilter,
                  onScopeChanged: (value) =>
                      ref.read(feedScopeProvider.notifier).select(value),
                  onSearchChanged: (value) =>
                      ref.read(postSearchQueryProvider.notifier).update(value),
                  onCategoryChanged: (value) =>
                      ref.read(selectedCategoryProvider.notifier).select(value),
                  onUkmChanged: (value) =>
                      ref.read(selectedFeedUkmProvider.notifier).select(value),
                  onReset: () => _resetFilters(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Postingan Terbaru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF122019),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3EE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${posts?.length ?? 0} postingan',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C6E49),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ..._buildContent(context, postsAsync, scope, hasFilter),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    AsyncValue<List<Post>> asyncPosts,
    FeedScope scope,
    bool hasFilter,
  ) {
    final posts = asyncPosts.value;

    if (posts == null) {
      if (asyncPosts.hasError) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _FeedState(
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat feed',
              message: 'Periksa koneksi lalu coba lagi.',
              actionLabel: 'Coba Lagi',
              onAction: () => ref.invalidate(feedPostsProvider),
            ),
          ),
        ];
      }

      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (posts.isEmpty) {
      final followed = ref.watch(followedUkmIdsProvider).value;
      final noFollowing =
          scope == FeedScope.following &&
          (followed == null || followed.isEmpty);

      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _FeedState(
            icon: noFollowing
                ? Icons.person_add_alt_1_rounded
                : Icons.filter_alt_off_rounded,
            title: noFollowing
                ? 'Belum mengikuti UKM'
                : 'Tidak ada postingan yang cocok',
            message: noFollowing
                ? 'Ikuti UKM dulu agar postingan terbarunya muncul di feed personal.'
                : 'Coba ubah kata kunci, kategori, atau UKM yang dipilih.',
            actionLabel: noFollowing
                ? 'Kembali ke Daftar UKM'
                : (hasFilter ? 'Reset Filter' : null),
            onAction: noFollowing
                ? () => Navigator.of(context).maybePop()
                : (hasFilter ? _resetFilters : null),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
        sliver: SliverList.separated(
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              post: post,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.ukmPostDetail,
                arguments: post,
              ),
            );
          },
        ),
      ),
    ];
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(postSearchQueryProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).clear();
    ref.read(selectedFeedUkmProvider.notifier).clear();
    ref.read(feedScopeProvider.notifier).select(FeedScope.all);
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E4D34), Color(0xFF2C6E49), Color(0xFF438765)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 20, 22),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onBack,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feed UKM',
                          style: TextStyle(
                            fontSize: 25,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kabar terbaru dari organisasi mahasiswa Unand.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: Color(0xFFD7E6DC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.scope,
    required this.selectedCategory,
    required this.selectedUkm,
    required this.ukms,
    required this.hasFilter,
    required this.onScopeChanged,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onUkmChanged,
    required this.onReset,
  });

  final TextEditingController searchController;
  final FeedScope scope;
  final String? selectedCategory;
  final String? selectedUkm;
  final List<Ukm> ukms;
  final bool hasFilter;
  final ValueChanged<FeedScope> onScopeChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onUkmChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final safeSelectedUkm = ukms.any((ukm) => ukm.id == selectedUkm)
        ? selectedUkm
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScopeToggle(selected: scope, onChanged: onScopeChanged),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14, color: Color(0xFF122019)),
            decoration: InputDecoration(
              hintText: 'Cari judul, isi, atau tag postingan...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A9A90),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFF5B6B61),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F6F3),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF9CC7AD),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: 'Semua',
                  selected: selectedCategory == null,
                  onTap: () => onCategoryChanged(null),
                ),
                for (final category in kFeedCategories) ...[
                  const SizedBox(width: 7),
                  _CategoryChip(
                    label: feedCategoryLabel(category),
                    selected: selectedCategory == category,
                    onTap: () => onCategoryChanged(category),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: safeSelectedUkm,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Color(0xFF5B6B61),
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF26382D),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'Semua UKM',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        for (final ukm in ukms)
                          DropdownMenuItem<String?>(
                            value: ukm.id,
                            child: Text(
                              ukm.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onUkmChanged,
                    ),
                  ),
                ),
              ),
              if (hasFilter) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C6E49),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.selected, required this.onChanged});

  final FeedScope selected;
  final ValueChanged<FeedScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final scope in FeedScope.values)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(scope),
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == scope
                        ? const Color(0xFF2C6E49)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    scope.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected == scope
                          ? Colors.white
                          : const Color(0xFF6B7A71),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF3EE) : const Color(0xFFF6F8F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF9CC7AD) : const Color(0xFFE3E9E4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? const Color(0xFF2C6E49) : const Color(0xFF6B7A71),
          ),
        ),
      ),
    );
  }
}

class _FeedState extends StatelessWidget {
  const _FeedState({
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
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
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF122019),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
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
