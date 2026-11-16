import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/follow_provider.dart';

enum FollowButtonVariant { list, detail }

/// Tombol Ikuti/Diikuti yang terhubung ke [followedUkmIdsProvider].
///
/// [FollowButtonVariant.list] dipakai di kartu daftar UKM (hijau),
/// [FollowButtonVariant.detail] dipakai di halaman profil (hitam seperti
/// desain terbaru).
/// Tombol bookmark pada kartu daftar UKM.
///
/// Mengikuti desain Figma: ikon bookmark di kanan atas kartu. Status follow
/// tetap memakai [followedUkmIdsProvider], hanya bentuk visualnya yang berbeda
/// dari [FollowButton].
class FollowBookmarkButton extends ConsumerWidget {
  const FollowBookmarkButton({super.key, required this.ukmId, this.ukmName});

  final String ukmId;
  final String? ukmName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(followedUkmIdsProvider);
    final following = followedAsync.value?.contains(ukmId) ?? false;
    final isLoading = followedAsync.isLoading;

    return Semantics(
      button: true,
      toggled: following,
      label: following ? 'Berhenti mengikuti UKM' : 'Ikuti UKM',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isLoading ? 0.55 : 1,
        child: IconButton(
          tooltip: following ? 'Diikuti' : 'Ikuti',
          onPressed: isLoading
              ? null
              : () async {
                  try {
                    await ref
                        .read(followedUkmIdsProvider.notifier)
                        .toggleFollow(ukmId);
                    if (!context.mounted) return;
                    final name = ukmName?.isNotEmpty == true ? ukmName : 'UKM';
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            following
                                ? 'Berhenti mengikuti $name.'
                                : 'Kamu mengikuti $name.',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gagal memperbarui status follow.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                  }
                },
          icon: Icon(
            following ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          ),
          iconSize: 24,
          color: following ? const Color(0xFF1E5B3A) : const Color(0xFF1B2430),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        ),
      ),
    );
  }
}

class FollowButton extends ConsumerWidget {
  const FollowButton({
    super.key,
    required this.ukmId,
    this.ukmName,
    this.variant = FollowButtonVariant.list,
  });

  final String ukmId;
  final String? ukmName;
  final FollowButtonVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(followedUkmIdsProvider);
    final following = followedAsync.value?.contains(ukmId) ?? false;
    final isLoading = followedAsync.isLoading;

    final isDetail = variant == FollowButtonVariant.detail;
    final backgroundColor = isDetail
        ? const Color(0xFF111111)
        : (following ? const Color(0xFFEAF3EE) : const Color(0xFF2C6E49));
    final foregroundColor = following && !isDetail
        ? const Color(0xFF2C6E49)
        : Colors.white;
    final label = isDetail
        ? (following ? 'Following' : 'Follow')
        : (following ? 'Diikuti' : 'Ikuti');

    final button = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(isDetail ? 24 : 20),
      child: InkWell(
        onTap: isLoading
            ? null
            : () async {
                try {
                  await ref
                      .read(followedUkmIdsProvider.notifier)
                      .toggleFollow(ukmId);
                  if (!context.mounted) return;
                  final name = ukmName?.isNotEmpty == true ? ukmName : 'UKM';
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          following
                              ? 'Berhenti mengikuti $name.'
                              : 'Kamu mengikuti $name.',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gagal memperbarui status follow.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                }
              },
        borderRadius: BorderRadius.circular(isDetail ? 24 : 20),
        child: Container(
          height: isDetail ? 48 : 34,
          width: isDetail ? double.infinity : 78,
          alignment: Alignment.center,
          padding: isDetail
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isDetail ? 15 : 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: isDetail ? 0.1 : 0,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: following ? 'Berhenti mengikuti UKM' : 'Ikuti UKM',
      child: opacityWhenLoading(button, isLoading),
    );
  }

  Widget opacityWhenLoading(Widget child, bool isLoading) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isLoading ? 0.55 : 1,
      child: child,
    );
  }
}
