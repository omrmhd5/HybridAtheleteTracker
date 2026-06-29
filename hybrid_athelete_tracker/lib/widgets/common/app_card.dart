import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

enum CardPadding { sm, md, lg }

/// Content surface container — the design system's `Card`.
/// White fill, 14px radius, hairline border, subtle shadow. Interactive
/// variant adds a ripple + slightly stronger shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final CardPadding padding;
  final bool interactive;
  final VoidCallback? onTap;
  final Color? accent;

  const AppCard({
    super.key,
    required this.child,
    this.padding = CardPadding.md,
    this.interactive = false,
    this.onTap,
    this.accent,
  });

  double get _pad => switch (padding) {
        CardPadding.sm => 12,
        CardPadding.md => 16,
        CardPadding.lg => 20,
      };

  @override
  Widget build(BuildContext context) {
    final tappable = interactive || onTap != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: accent ?? AppColors.surfaceBorder,
          width: accent != null ? 1.5 : 1,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: tappable ? AppColors.primaryDim : Colors.transparent,
          highlightColor: tappable ? AppColors.primaryDim : Colors.transparent,
          child: Padding(padding: EdgeInsets.all(_pad), child: child),
        ),
      ),
    );
  }
}
