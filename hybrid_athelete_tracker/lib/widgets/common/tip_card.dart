import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// AI Coach insight card — inverted dark surface, white text, mint spark marker.
class TipCard extends StatelessWidget {
  final String title;
  final String body;
  final String? footer;

  const TipCard({
    super.key,
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.sans(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppTextStyles.sans(
              size: 15,
              color: Colors.white,
              height: 1.45,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            Text(
              footer!,
              style: AppTextStyles.sans(
                size: 11,
                weight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
