import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/app_colors.dart';

class AnimatedProgressTracker extends StatefulWidget {
  final String currentStatus;

  const AnimatedProgressTracker({
    super.key,
    required this.currentStatus,
  });

  @override
  State<AnimatedProgressTracker> createState() =>
      _AnimatedProgressTrackerState();
}

class _AnimatedProgressTrackerState extends State<AnimatedProgressTracker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  static const List<String> _stages = [
    'Applied',
    'Under Review',
    'Interview',
    'Decision',
  ];

  int get _activeIndex {
    switch (widget.currentStatus) {
      case 'Under Review':
        return 1;
      case 'Interview':
        return 2;
      case 'Offer':
      case 'Rejected':
      case 'Withdrawn':
        return 3;
      default:
        return 0; // 'Applied'
    }
  }

  bool get _isTerminal =>
      widget.currentStatus == 'Offer' ||
      widget.currentStatus == 'Rejected' ||
      widget.currentStatus == 'Withdrawn';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    if (!_isTerminal) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isTerminal) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? AppColors.background
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) {
          return CustomPaint(
            painter: _StepperTrackPainter(
              activeIndex: _activeIndex,
              isTerminal: _isTerminal,
              animationValue: _pulseAnimation.value,
              isDark: AppColors.isDark,
              activeColor: AppColors.primaryBlue,
            ),
            foregroundPainter: _StepperForegroundPainter(
              activeIndex: _activeIndex,
              isTerminal: _isTerminal,
              animationValue: _pulseAnimation.value,
              activeColor: AppColors.primaryBlue,
            ),
            child: Row(
              children: List.generate(_stages.length, _buildStageColumn),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageColumn(int index) {
    final isCompleted = index <= _activeIndex &&
        widget.currentStatus != 'Rejected' &&
        widget.currentStatus != 'Withdrawn';
    final isCurrent = index == _activeIndex;
    final isRejected = widget.currentStatus == 'Rejected' && index == 3;
    final isWithdrawn = widget.currentStatus == 'Withdrawn' && index == 3;

    Color nodeColor = AppColors.isDark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
    if (isRejected) {
      nodeColor = const Color(0xFFDC2626);
    } else if (isWithdrawn) {
      nodeColor = const Color(0xFF64748B);
    } else if (isCompleted) {
      nodeColor = AppColors.primaryBlue;
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNodeCircle(
            isCompleted: isCompleted,
            isRejected: isRejected,
            isWithdrawn: isWithdrawn,
            nodeColor: nodeColor,
          ),
          const SizedBox(height: 7),
          Text(
            _stages[index],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: isCurrent
                  ? AppColors.heading
                  : (isCompleted ? AppColors.heading : AppColors.hintText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCircle({
    required bool isCompleted,
    required bool isRejected,
    required bool isWithdrawn,
    required Color nodeColor,
  }) {
    final Color effectiveBg = (isCompleted || isRejected || isWithdrawn)
        ? nodeColor
        : AppColors.surface;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: nodeColor,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
            : (isRejected || isWithdrawn)
                ? const Icon(Icons.close_rounded, size: 13, color: Colors.white)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
      ),
    );
  }
}

/// Paints background tracks and the active line oscillating from midpoint to circle.
class _StepperTrackPainter extends CustomPainter {
  final int activeIndex;
  final bool isTerminal;
  final double animationValue;
  final bool isDark;
  final Color activeColor;

  _StepperTrackPainter({
    required this.activeIndex,
    required this.isTerminal,
    required this.animationValue,
    required this.isDark,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double nodeY = 11.0;
    final double slotW = size.width / 4;
    final trackColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final solidPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final double startX = slotW * (i + 0.5);
      final double endX = slotW * (i + 1.5);

      if (i < activeIndex) {
        canvas.drawLine(
          Offset(startX, nodeY),
          Offset(endX, nodeY),
          solidPaint,
        );
      } else if (i == activeIndex && !isTerminal) {
        canvas.drawLine(
          Offset(startX, nodeY),
          Offset(endX, nodeY),
          trackPaint,
        );

        final double midX = (startX + endX) / 2;
        const double circleRadius = 10.0;
        final double circleTouchX = endX - circleRadius;
        final double totalDist = (endX + circleRadius) - midX;
        final double headX = midX + totalDist * animationValue;

        final double lineEnd = headX.clamp(midX, circleTouchX);
        canvas.drawLine(
          Offset(startX, nodeY),
          Offset(lineEnd, nodeY),
          solidPaint,
        );
      } else {
        canvas.drawLine(
          Offset(startX, nodeY),
          Offset(endX, nodeY),
          trackPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StepperTrackPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.isTerminal != isTerminal;
  }
}

/// Paints the left-to-right sweep on the target circle's border only.
class _StepperForegroundPainter extends CustomPainter {
  final int activeIndex;
  final bool isTerminal;
  final double animationValue;
  final Color activeColor;

  _StepperForegroundPainter({
    required this.activeIndex,
    required this.isTerminal,
    required this.animationValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isTerminal || activeIndex >= 3) return;

    const double nodeY = 11.0;
    final double slotW = size.width / 4;
    final double startX = slotW * (activeIndex + 0.5);
    final double endX = slotW * (activeIndex + 1.5);

    final double midX = (startX + endX) / 2;
    const double circleRadius = 10.0;
    final double circleTouchX = endX - circleRadius;
    final double totalDist = (endX + circleRadius) - midX;
    final double headX = midX + totalDist * animationValue;

    if (headX > circleTouchX) {
      final double circleProgress =
          ((headX - circleTouchX) / (2 * circleRadius)).clamp(0.0, 1.0);

      final arcPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: Offset(endX, nodeY),
        radius: circleRadius,
      );

      final double sweep = math.pi * circleProgress;
      if (circleProgress >= 0.999) {
        canvas.drawCircle(Offset(endX, nodeY), circleRadius, arcPaint);
      } else if (circleProgress > 0.001) {
        // Upper arc sweeps counter-clockwise (upward) from left (π) towards right (0)
        canvas.drawArc(rect, math.pi, -sweep, false, arcPaint);
        // Lower arc sweeps clockwise (downward) from left (π) towards right (0)
        canvas.drawArc(rect, math.pi, sweep, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StepperForegroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.activeIndex != activeIndex;
  }
}
