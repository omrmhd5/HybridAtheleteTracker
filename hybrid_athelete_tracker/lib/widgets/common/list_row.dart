import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// Icon chip · title/subtitle · trailing — the design system's list `Row`.
class ListRow extends StatelessWidget {
  final IconData? icon;
  final Color iconBg;
  final Color iconColor;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    this.icon,
    this.iconBg = AppColors.primaryDim,
    this.iconColor = AppColors.primary,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.sans(size: 15, weight: FontWeight.w600),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: AppTextStyles.sans(
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: row,
    );
  }
}
