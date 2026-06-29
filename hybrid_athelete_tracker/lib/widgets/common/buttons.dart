import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

enum HAButtonVariant { primary, secondary, ghost }

enum HAButtonSize { md, lg }

/// CTA / action button with a tactile scale(.97) press.
/// primary = mint fill, secondary = mint-dim fill, ghost = bordered.
class HAButton extends StatefulWidget {
  final String? label;
  final HAButtonVariant variant;
  final HAButtonSize size;
  final bool fullWidth;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconRight;
  final bool loading;

  const HAButton({
    super.key,
    this.label,
    this.variant = HAButtonVariant.primary,
    this.size = HAButtonSize.lg,
    this.fullWidth = false,
    this.onPressed,
    this.icon,
    this.iconRight = false,
    this.loading = false,
  });

  @override
  State<HAButton> createState() => _HAButtonState();
}

class _HAButtonState extends State<HAButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final height = widget.size == HAButtonSize.lg ? 52.0 : 44.0;

    final (bg, fg, border) = switch (widget.variant) {
      HAButtonVariant.primary => (AppColors.primary, Colors.white, null),
      HAButtonVariant.secondary => (
          AppColors.primaryDim,
          AppColors.primary,
          null,
        ),
      HAButtonVariant.ghost => (
          Colors.transparent,
          AppColors.textPrimary,
          const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
    };

    final iconWidget =
        widget.icon != null ? Icon(widget.icon, size: 19, color: fg) : null;

    final content = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null && !widget.iconRight) ...[
                iconWidget,
                if (widget.label != null) const SizedBox(width: 8),
              ],
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: AppTextStyles.sans(
                    size: 15,
                    weight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              if (iconWidget != null && widget.iconRight) ...[
                if (widget.label != null) const SizedBox(width: 8),
                iconWidget,
              ],
            ],
          );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            height: height,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.label == null ? 14 : 20,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: border != null ? Border.fromBorderSide(border) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
