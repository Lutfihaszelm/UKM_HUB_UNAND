// lib/widgets/profile_avatar.dart
// ===========================================================================
// ProfileAvatar — Widget Avatar Profil yang dapat dipakai ulang di seluruh app.
// Menampilkan foto profil pengguna dari file/asset, atau inisial jika tidak ada.
// ===========================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final imagePath = storage.profileImagePath;
    final initial = storage.displayName.isNotEmpty
        ? storage.displayName[0].toUpperCase()
        : 'U';

    final avatarChild = _buildImage(imagePath, initial);

    if (borderColor != null && borderWidth > 0) {
      return Container(
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: borderColor,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF2C6E49),
          child: avatarChild,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2C6E49),
      child: avatarChild,
    );
  }

  Widget _buildImage(String imagePath, String initial) {
    if (imagePath.startsWith('assets/')) {
      // Asset image
      return ClipOval(
        child: Image.asset(
          imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitial(initial),
        ),
      );
    } else {
      // File image dari image_picker
      final file = File(imagePath);
      return ClipOval(
        child: Image.file(
          file,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitial(initial),
        ),
      );
    }
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

