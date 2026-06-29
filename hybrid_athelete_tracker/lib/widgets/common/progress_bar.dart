import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Goal progress indicator — rounded track with mint fill, animated width.
class HAProgressBar extends StatelessWidget {
  final double value; // current
  final double max;
  final double height;
  final Color? color;

  const HAProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.height = 12,
    this.color,
  });

  const HAProgressBar.lg({
    super.key,
    required this.value,
    required this.max,
    this.color,
  }) : height = 12;

  @override
  Widget build(BuildContext context) {
    final pct = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, c) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: c.maxWidth * pct,
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
