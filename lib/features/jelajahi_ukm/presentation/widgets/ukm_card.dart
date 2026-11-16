import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/follow_provider.dart';
import '../../models/ukm.dart';
import 'follow_button.dart';
import 'ukm_logo_view.dart';

/// Kartu UKM pada halaman "Jelajahi UKM".
///
/// Mengikuti desain Figma terbaru: kartu putih ringkas, logo di kiri, nama
/// hijau, bookmark follow di kanan atas, avatar anggota, dan tombol "More".
class UkmCard extends ConsumerWidget {
  const UkmCard({super.key, required this.ukm, this.onTap});

  final Ukm ukm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(isFollowingUkmProvider(ukm.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UkmLogoView(
                      logoUrl: ukm.logoUrl,
                      fallbackIcon: ukm.icon,
                      color: ukm.color,
                      size: 52,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    ukm.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.1,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E5B3A),
                                    ),
                                  ),
                                ),
                              ),
                              FollowBookmarkButton(
                                ukmId: ukm.id,
                                ukmName: ukm.name,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ukm.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              height: 1.3,
                              color: Color(0xFF8C9A92),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const _MemberStack(),
                              const SizedBox(width: 4),
                              Semantics(
                                label: 'Lebih dari 20 anggota',
                                child: const Text(
                                  '>20',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _MoreBar(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tumpukan avatar anggota. Untuk sementara memakai avatar generik sampai
/// backend menyediakan foto anggota.
class _MemberStack extends StatelessWidget {
  const _MemberStack();

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF7BAE8C), Color(0xFFE0B15A), Color(0xFF89A7C7)];

    return SizedBox(
      width: 31,
      height: 18,
      child: Stack(
        children: [
          for (var index = 0; index < colors.length; index++)
            Positioned(
              left: index * 6.5,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoreBar extends StatelessWidget {
  const _MoreBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFC7DBD0)],
          stops: [0.3, 1],
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'More',
            style: TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF122019),
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF122019)),
        ],
      ),
    );
  }
}
