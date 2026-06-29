import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// Floating action button — circular by default, extended pill with a label.
/// Mint fill with a soft primary glow.
class HAFab extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color color;

  const HAFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final extended = label != null;
    return Material(
      color: color,
      elevation: 0,
      borderRadius: BorderRadius.circular(extended ? AppRadius.lg : AppRadius.full),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(extended ? AppRadius.lg : AppRadius.full),
        child: Container(
          height: 52,
          width: extended ? null : 52,
          padding: EdgeInsets.symmetric(horizontal: extended ? 20 : 0),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(extended ? AppRadius.lg : AppRadius.full),
            boxShadow: AppColors.shadowPrimary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              if (extended) ...[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: AppTextStyles.sans(
                    size: 15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
