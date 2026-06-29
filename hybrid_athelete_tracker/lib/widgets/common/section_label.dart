import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Small section heading above a list — 13px / 600 / secondary.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 13,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
