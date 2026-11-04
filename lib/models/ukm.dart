import 'package:flutter/material.dart';

/// Model representing a student organization (UKM).
class Ukm {
  const Ukm({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.kategori = 'Umum',
    this.contact,
    this.logoUrl,
  });

  /// Unique identifier for the UKM.
  final String id;

  final String name;
  final String description;
  final IconData icon;

  /// Accent color used for the icon and its background tint on the card.
  final Color color;

  /// Category of the UKM (e.g. 'Seni', 'Olahraga', 'Teknologi').
  final String kategori;

  /// Optional contact info (e.g. Instagram handle or email).
  final String? contact;

  /// Optional logo URL. null = use icon fallback.
  final String? logoUrl;
}
