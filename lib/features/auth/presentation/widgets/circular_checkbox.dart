import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Small checkbox used for "Ingat saya".
class CircularCheckbox extends StatelessWidget {
  const CircularCheckbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: value ? AppColors.primaryGreenDark : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primaryGreenDark : const Color(0xFF94A3B8),
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}
