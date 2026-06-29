import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Mini macro bar — label + grams value + thin progress bar.
/// `dim` renders carbs/fat in a neutral grey instead of the mint accent.
class MacroBar extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final bool dim;

  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(
              '${value}g',
              style: AppTextStyles.sans(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, c) => Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: c.maxWidth * pct,
                decoration: BoxDecoration(
                  color: dim ? const Color(0xFFC4C8CF) : AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
