import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

enum BadgeVariant { primary, success, neutral }

/// Status / quantity chip — pill shape, tinted fill.
class HABadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const HABadge(this.label, {super.key, this.variant = BadgeVariant.primary});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      BadgeVariant.primary => (AppColors.primaryDim, AppColors.primary),
      BadgeVariant.success => (AppColors.successDim, AppColors.success),
      BadgeVariant.neutral => (AppColors.surfaceLight, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.sans(size: 12, weight: FontWeight.w700, color: fg),
      ),
    );
  }
}
