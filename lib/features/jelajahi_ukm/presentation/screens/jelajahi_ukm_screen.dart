import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/jelajahi_ukm_provider.dart';
import '../widgets/ukm_card.dart';

/// FR-01: Jelajahi & Cari UKM screen.
///
/// Clean, spacious organization directory matching the original reference:
/// - Prominent title and descriptive subtitle
/// - Generously padded search field with green focus state
/// - Section header with soft-green pill count badge
/// - Proportional, comfortably padded cards with wrapped descriptions
/// - Desktop-responsive layout centered and constrained to a comfortable width
/// - Adaptive sliver layout that gracefully handles keyboard open states without overflow
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                // ── Header section (Title, Subtitle, Search Field, Section Header) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jelajahi UKM',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kenali berbagai organisasi dan kegiatan mahasiswa di Universitas Andalas.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Search field ──
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref
                                .read(searchQueryProvider.notifier)
                                .update(value);
                          },
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama UKM...',
                            hintStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 12),
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                                size: 22,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFF2C6E49),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Section heading with result count badge ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Daftar Organisasi Kampus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredList.length} UKM',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C6E49),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // ── Organization list or empty state ──
                if (filteredList.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'UKM tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Coba kata kunci lain.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return UkmCard(ukm: filteredList[index]);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
