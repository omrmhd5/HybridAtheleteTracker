import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Circular avatar with initials fallback (mint-dim fill, mint text).
class InitialsAvatar extends StatelessWidget {
  final String text;
  final double size;

  const InitialsAvatar({super.key, required this.text, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryDim,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: AppTextStyles.sans(
          size: size * 0.34,
          weight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Derives up to two uppercase initials from a name.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
