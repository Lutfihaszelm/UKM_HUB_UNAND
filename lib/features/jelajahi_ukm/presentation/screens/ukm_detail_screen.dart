import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_routes.dart';
import '../../application/follow_provider.dart';
import '../../application/jelajahi_ukm_provider.dart';
import '../../models/ukm.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';
import '../widgets/follow_button.dart';
import '../widgets/post_card.dart';
import '../widgets/ukm_logo_view.dart';

/// FR-02: Detail profil UKM.
///
/// Struktur mengikuti desain referensi: hero gelap dengan tombol kembali,
/// lembar putih melengkung dengan logo di tengah, nama UKM, tombol Follow
/// hitam, baris kontak, tab Deskripsi/Postingan berbentuk pill, lalu isi tab.
class UkmDetailScreen extends ConsumerStatefulWidget {
  const UkmDetailScreen({super.key, required this.ukm});

  final Ukm ukm;

  @override
  ConsumerState<UkmDetailScreen> createState() => _UkmDetailScreenState();
}

class _UkmDetailScreenState extends ConsumerState<UkmDetailScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(ukmDetailProvider(widget.ukm.id));
    final ukm = detailAsync.value ?? widget.ukm;
    final following = ref.watch(isFollowingUkmProvider(ukm.id));
    final followerCount = followerCountForDisplay(
      baseCount: ukm.followerCount,
      followedByMe: ukm.followedByMe,
      following: following,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HeroBackdrop(ukm: ukm)),
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        _ProfileHeader(
                          ukm: ukm,
                          followerCount: followerCount,
                          tabIndex: _tabIndex,
                          onTabChanged: (index) =>
                              setState(() => _tabIndex = index),
                        ),
                        _tabIndex == 0
                            ? _DescriptionTab(ukm: ukm)
                            : _PostsTab(ukm: ukm),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Tombol kembali tetap di atas saat konten digulir.
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _CircleAction(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Kembali',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero atas: foto UKM yang diburamkan, digelapkan agar judul tetap terbaca,
/// dengan tombol kembali melayang di atasnya.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop({required this.ukm});

  final Ukm ukm;

  static const String _fallbackImage = 'assets/images/bemkm.jpg';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final banner = ukm.bannerUrl?.trim();

    return SizedBox(
      height: topPadding + 148,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Transform.scale(
              scale: 1.12,
              child: AppImage(
                path: (banner == null || banner.isEmpty)
                    ? _fallbackImage
                    : banner,
                fallback: const ColoredBox(color: Color(0xFF14251B)),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.55, 1],
                colors: [
                  Color(0xCC0B1710),
                  Color(0xA614251B),
                  Color(0xFF14251B),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPadding + 16,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Profil UKM',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: Color(0xFFDCEBE1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.ukm,
    required this.followerCount,
    required this.tabIndex,
    required this.onTabChanged,
  });

  final Ukm ukm;
  final int followerCount;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo menjorok ke area gelap di atas lembar putih.
        Transform.translate(
          offset: const Offset(0, -26),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: UkmLogoView(
                logoUrl: ukm.logoUrl,
                fallbackIcon: ukm.icon,
                color: ukm.color,
                size: 84,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ukm.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: Color(0xFF122019),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ukm.isVerified) ...[
              const Icon(
                Icons.verified_rounded,
                size: 15,
                color: Color(0xFF2C6E49),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              '${formatCount(followerCount)} pengikut',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7A71),
              ),
            ),
            if (ukm.category != null) ...[
              const SizedBox(width: 5),
              const Text(
                '·',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFF9AA89F),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                ukm.category!,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7A71),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FollowButton(
            ukmId: ukm.id,
            ukmName: ukm.name,
            variant: FollowButtonVariant.detail,
          ),
        ),
        const SizedBox(height: 16),
        _ContactList(ukm: ukm),
        const SizedBox(height: 12),
        _TabBar(selectedIndex: tabIndex, onChanged: onTabChanged),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 17, color: const Color(0xFF1B2A20)),
          ),
        ),
      ),
    );
  }
}

class _ContactData {
  const _ContactData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _ContactList extends StatelessWidget {
  const _ContactList({required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context) {
    var rows = <_ContactData>[
      if (ukm.email != null && ukm.email!.trim().isNotEmpty)
        _ContactData(
          label: 'Email',
          value: ukm.email!,
          icon: Icons.mail_outline_rounded,
        ),
      if (ukm.instagram != null && ukm.instagram!.trim().isNotEmpty)
        _ContactData(
          label: 'Instagram',
          value: ukm.instagram!,
          icon: Icons.camera_alt_outlined,
        ),
      if (ukm.website != null && ukm.website!.trim().isNotEmpty)
        _ContactData(
          label: 'Website',
          value: ukm.website!,
          icon: Icons.language_rounded,
        ),
    ];

    // Fallback untuk data API yang hanya punya satu field `contact`.
    if (rows.isEmpty && ukm.contact != null && ukm.contact!.trim().isNotEmpty) {
      rows = [
        _ContactData(
          label: 'Kontak',
          value: ukm.contact!,
          icon: Icons.contact_phone_outlined,
        ),
      ];
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(children: [for (final row in rows) _ContactRow(data: row)]),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.data});

  final _ContactData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: data.value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '${data.label} disalin.',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(data.icon, size: 19, color: const Color(0xFF39463E)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26382D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1EE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Deskripsi',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            label: 'Postingan',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 38,
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? const Color(0xFF122019) : const Color(0xFF5F6B63),
        ),
      ),
    );

    if (!selected) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: content,
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Detail'),
          const SizedBox(height: 8),
          Text(
            ukm.description,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13.5,
              height: 1.65,
              color: Color(0xFF45584B),
            ),
          ),
          if (ukm.history != null && ukm.history!.trim().isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Sejarah'),
            const SizedBox(height: 8),
            Text(
              ukm.history!,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.5,
                height: 1.65,
                color: Color(0xFF45584B),
              ),
            ),
          ],
          if (ukm.hasOpenOprec) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF4DFB4)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 20,
                    color: Color(0xFFB45309),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'UKM ini sedang membuka open recruitment. '
                      'Cek tab Postingan untuk informasi terbaru.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF8A5A16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF122019),
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.ukm});

  final Ukm ukm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(ukmPostsProvider(ukm.id));
    final posts = postsAsync.value;

    if (posts == null) {
      if (postsAsync.hasError) {
        return _TabState(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal memuat postingan',
          message: 'Coba lagi beberapa saat lagi.',
          actionLabel: 'Coba Lagi',
          onAction: () => ref.invalidate(ukmPostsProvider(ukm.id)),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 42),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (posts.isEmpty) {
      return const _TabState(
        icon: Icons.article_outlined,
        title: 'Belum ada postingan',
        message: 'Postingan terbaru UKM ini akan muncul di sini.',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        children: [
          for (var i = 0; i < posts.length; i++) ...[
            PostCard(
              post: posts[i],
              variant: PostCardVariant.detail,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.ukmPostDetail,
                arguments: posts[i],
              ),
            ),
            if (i != posts.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TabState extends StatelessWidget {
  const _TabState({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 34),
      child: Column(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF9AA89F)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF26382D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF6B7A71),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
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
    );
  }
}
