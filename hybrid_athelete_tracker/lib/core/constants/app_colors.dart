import 'package:flutter/material.dart';

/// Color tokens ported from the Hybrid Athlete design system (light mode).
/// Single mint-green accent — no secondary accent color.
class AppColors {
  // ── Surfaces ──────────────────────────────
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFEEEEF0);
  static const Color surfaceBorder = Color(0x12111318); // rgba(17,19,24,.07)

  // ── Text ──────────────────────────────────
  static const Color textPrimary = Color(0xFF111318);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ── Accent (single brand color) ───────────
  static const Color primary = Color(0xFF00C27C);
  static const Color primaryLight = Color(0xFF33D895);
  static const Color primaryDim = Color(0x1A00C27C); // rgba(0,194,124,.10)

  // ── Semantic ──────────────────────────────
  static const Color success = Color(0xFF00C27C);
  static const Color successDim = Color(0x1A00C27C);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDim = Color(0x1AEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDim = Color(0x1AF59E0B);

  // ── Shadows ───────────────────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(color: Color(0x4700C27C), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
