import 'package:flutter/material.dart';

/// Smooth and modern fade + slide transition builder for all page routes.
class SmoothFadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothFadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primaryCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Primary route slides in from the right edge (+1.0) and fades in
    final primarySlide = SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(primaryCurved),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(primaryCurved),
        child: child,
      ),
    );

    // Underlying screen shifts left (-0.25) when covered
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.25, 0),
      ).animate(secondaryCurved),
      child: primarySlide,
    );
  }
}

/// Helper function to create directional tab transitions (slide left or right).
Route<T> createDirectionalPageRoute<T>({
  required Widget page,
  required bool isMovingRight,
  Duration duration = const Duration(milliseconds: 360),
}) {
  final beginOffset =
      isMovingRight ? const Offset(0.08, 0) : const Offset(-0.08, 0);

  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.15, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Helper function to create a custom smooth animated page route (for detail/child screens).
Route<T> createSmoothPageRoute<T>({
  required Widget page,
  Duration duration = const Duration(milliseconds: 360),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: child,
        ),
      );
    },
  );
}


