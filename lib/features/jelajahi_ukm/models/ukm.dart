import 'package:flutter/material.dart';

/// Model UKM untuk Modul 1.
///
/// Field utama mengikuti kontrak API `docs/api-contract.md` (Objek UKM):
/// id, name, description, contact, logo_url, banner_url, is_verified,
/// follower_count, followed_by_me, has_open_oprec.
///
/// Field tambahan (icon, color, category, instagram, email, website, history)
/// hanya dipakai untuk tampilan/data dummy sampai backend menyediakan field
/// tersebut. Saat integrasi API, field ini boleh dibiarkan null dan UI akan
/// menyembunyikan baris yang kosong.
class Ukm {
  const Ukm({
    required this.id,
    required this.name,
    required this.description,
    this.contact,
    this.logoUrl,
    this.bannerUrl,
    this.isVerified = true,
    this.followerCount = 0,
    this.followedByMe = false,
    this.hasOpenOprec = false,
    this.icon = Icons.groups_rounded,
    this.color = const Color(0xFF2C6E49),
    this.category,
    this.instagram,
    this.email,
    this.website,
    this.history,
  });

  final String id;
  final String name;
  final String description;

  /// Kontak utama dari API (bisa email, Instagram, atau URL).
  final String? contact;
  final String? logoUrl;
  final String? bannerUrl;
  final bool isVerified;
  final int followerCount;
  final bool followedByMe;
  final bool hasOpenOprec;

  /// Metadata tampilan (bukan bagian dari kontrak API).
  final IconData icon;
  final Color color;
  final String? category;
  final String? instagram;
  final String? email;
  final String? website;

  /// Teks profil tambahan untuk section "Sejarah".
  /// Sementara hanya tersedia di data dummy; backend belum punya field ini.
  final String? history;

  Ukm copyWith({
    String? id,
    String? name,
    String? description,
    String? contact,
    String? logoUrl,
    String? bannerUrl,
    bool? isVerified,
    int? followerCount,
    bool? followedByMe,
    bool? hasOpenOprec,
    IconData? icon,
    Color? color,
    String? category,
    String? instagram,
    String? email,
    String? website,
    String? history,
  }) {
    return Ukm(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isVerified: isVerified ?? this.isVerified,
      followerCount: followerCount ?? this.followerCount,
      followedByMe: followedByMe ?? this.followedByMe,
      hasOpenOprec: hasOpenOprec ?? this.hasOpenOprec,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      instagram: instagram ?? this.instagram,
      email: email ?? this.email,
      website: website ?? this.website,
      history: history ?? this.history,
    );
  }

  factory Ukm.fromJson(Map<String, dynamic> json) {
    return Ukm(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      contact: json['contact'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      followedByMe: json['followed_by_me'] as bool? ?? false,
      hasOpenOprec: json['has_open_oprec'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contact': contact,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'is_verified': isVerified,
      'follower_count': followerCount,
      'followed_by_me': followedByMe,
      'has_open_oprec': hasOpenOprec,
    };
  }
}

/// Hasil endpoint follow/unfollow: `{"data": {"followed": true,
/// "follower_count": 121}}`.
class FollowResult {
  const FollowResult({required this.followed, required this.followerCount});

  final bool followed;
  final int followerCount;

  factory FollowResult.fromJson(Map<String, dynamic> json) {
    return FollowResult(
      followed: json['followed'] as bool? ?? false,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
    );
  }
}
