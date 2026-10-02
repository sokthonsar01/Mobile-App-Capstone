import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/page_transitions.dart';
import '../../home/data/internship_model.dart';
import 'application_details_screen.dart';
import '../../home/presentation/home_screen.dart';

/// Full-screen animated Success view displayed after submitting an internship application.
class ApplicationSubmittedScreen extends StatefulWidget {
  final InternshipOpportunity? internship;

  const ApplicationSubmittedScreen({
    super.key,
    this.internship,
  });

  @override
  State<ApplicationSubmittedScreen> createState() =>
      _ApplicationSubmittedScreenState();
}

class _ApplicationSubmittedScreenState extends State<ApplicationSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _circleAnimation;
  late final Animation<double> _checkAnimation;
  late final Animation<double> _contentFadeAnimation;
  late final Animation<Offset> _contentSlideAnimation;
  late final Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();
    // 2200ms total allows generous pacing so the user clearly sees both strokes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Initial scale is 0.94 (not 0.0), so circle is prominent and clear from frame 1
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.94, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 10,
      ),
    ]).animate(_controller);

    // Circle ring draws clockwise in the first ~770ms
    _circleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeInOutCubic),
    );

    // Dedicated ~880ms interval for checkmark drawing (0.42 to 0.82)
    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.82, curve: Curves.easeInOutCubic),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.90, curve: Curves.easeOut),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.90, curve: Curves.easeOutCubic),
    ));

    _buttonsFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    // Start drawing strictly AFTER the screen route transition settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeAnimation = ModalRoute.of(context)?.animation;
      if (routeAnimation != null && !routeAnimation.isCompleted) {
        void onRouteComplete(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            routeAnimation.removeStatusListener(onRouteComplete);
            Future.delayed(const Duration(milliseconds: 240), () {
              if (mounted) _controller.forward();
            });
          }
        }

        routeAnimation.addStatusListener(onRouteComplete);
      } else {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBackToHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pushReplacement(
        createDirectionalPageRoute(
          page: const HomeScreen(),
          isMovingRight: false,
        ),
      );
    }
  }

  void _handleViewApplication(InternshipOpportunity? item) {
    Navigator.of(context).pushReplacement(
      createSmoothPageRoute(
        page: ApplicationDetailsScreen(
          internship: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.internship;

    return Scaffold(
      backgroundColor: const Color(0xFF2B59FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => _controller.forward(from: 0.0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => _AnimatedSuccessCheckmark(
                    circleProgress: _circleAnimation.value,
                    checkProgress: _checkAnimation.value,
                    scale: _scaleAnimation.value,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: SlideTransition(
                    position: _contentSlideAnimation,
                    child: _buildTextContent(),
                  ),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => FadeTransition(
                  opacity: _buttonsFadeAnimation,
                  child: _buildActionButtons(item),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Application submitted',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'You will be notified if you are shortlisted.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(InternshipOpportunity? item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _handleBackToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2B59FF),
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Back to Home',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => _handleViewApplication(item),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            'View Application',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedSuccessCheckmark extends StatelessWidget {
  final double circleProgress;
  final double checkProgress;
  final double scale;

  const _AnimatedSuccessCheckmark({
    required this.circleProgress,
    required this.checkProgress,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 104,
        height: 104,
        child: CustomPaint(
          painter: _SuccessCheckmarkPainter(
            circleProgress: circleProgress,
            checkProgress: checkProgress,
          ),
        ),
      ),
    );
  }
}

class _SuccessCheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;

  _SuccessCheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4.0;

    // 0. Base circle track so boundary is clearly visible from frame 1
    final baseTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, baseTrackPaint);

    // 1. Soft illuminated background fill inside circle
    if (circleProgress > 0.0) {
      final fillPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.10 * circleProgress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);
    }

    // 2. Draw outer circle ring clockwise from 12 o'clock (-pi/2)
    if (circleProgress > 0.0) {
      final circlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * circleProgress.clamp(0.0, 1.0),
        false,
        circlePaint,
      );
    }

    // 3. Ripple pulse wave upon check completion
    if (checkProgress > 0.75) {
      final rippleProgress = (checkProgress - 0.75) / 0.25;
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45 * (1.0 - rippleProgress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(center, radius + (16 * rippleProgress), ripplePaint);
    }

    // 4. Draw animated checkmark stroke from left to bottom to top-right
    if (checkProgress > 0.0) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      const start = Offset(32, 53);
      const mid = Offset(47, 68);
      const end = Offset(74, 39);

      path.moveTo(start.dx, start.dy);

      final p = checkProgress.clamp(0.0, 1.0);
      if (p <= 0.38) {
        final f = Curves.easeOut.transform(p / 0.38);
        path.lineTo(
          start.dx + (mid.dx - start.dx) * f,
          start.dy + (mid.dy - start.dy) * f,
        );
      } else {
        path.lineTo(mid.dx, mid.dy);
        final f = Curves.easeOutCubic.transform((p - 0.38) / 0.62);
        path.lineTo(
          mid.dx + (end.dx - mid.dx) * f,
          mid.dy + (end.dy - mid.dy) * f,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessCheckmarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress;
  }
}
