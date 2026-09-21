import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Small filled-circle checkbox used for "Ingat saya".
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
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? AppColors.accentGreen : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.accentGreen : AppColors.borderInput,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 14, color: AppColors.textOnButton)
            : null,
      ),
    );
  }
}
