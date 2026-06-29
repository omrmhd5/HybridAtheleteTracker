import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// Boxed stepper — big centered value with −/+ buttons (+ uses mint-dim).
class StepperField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String suffix;

  const StepperField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 14,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _btn(false, value > min),
          Text.rich(
            TextSpan(
              text: '$value',
              style: AppTextStyles.sans(size: 22, weight: FontWeight.w700),
              children: [
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: suffix,
                    style: AppTextStyles.sans(
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          _btn(true, value < max),
        ],
      ),
    );
  }

  Widget _btn(bool inc, bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(value + (inc ? 1 : -1)) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: inc ? AppColors.primaryDim : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            inc ? Icons.add : Icons.remove,
            size: 20,
            color: inc ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Inline labelled stat field — label on the left, −value+ on the right.
class StatField extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;
  final int step;

  const StatField({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.sans(
              size: 15,
              weight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              _round(false),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text.rich(
                  TextSpan(
                    text: '$value',
                    style:
                        AppTextStyles.sans(size: 19, weight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.sans(
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _round(true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _round(bool inc) {
    return GestureDetector(
      onTap: () => onChanged(value + (inc ? step : -step)),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: inc ? AppColors.primaryDim : AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          inc ? Icons.add : Icons.remove,
          size: 18,
          color: inc ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
