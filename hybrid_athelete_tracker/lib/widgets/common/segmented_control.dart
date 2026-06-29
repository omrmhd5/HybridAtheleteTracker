import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const SegmentOption({required this.value, required this.label, this.icon});
}

/// Segmented control — active segment is a white pill with a shadow.
class SegmentedControl<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: options.map((o) {
          final active = o.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: active ? AppColors.shadowSm : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (o.icon != null) ...[
                      Icon(
                        o.icon,
                        size: 17,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        o.label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sans(
                          size: 13,
                          weight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
