import 'package:flutter/material.dart';

/// Pushes a full-screen overlay with a horizontal slide, matching the
/// prototype's in-frame overlays (LiveLog, Camera, Plan, Profile, FuelDetail).
extension OverlayNav on BuildContext {
  Future<T?> pushScreen<T>(Widget screen) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }
}
