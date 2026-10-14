import 'package:flutter/material.dart';

/// Model representing a student organization (UKM).
class Ukm {
  const Ukm({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String name;
  final String description;
  final IconData icon;

  /// Accent color used for the icon and its background tint on the card.
  final Color color;
}
