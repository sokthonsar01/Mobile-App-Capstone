import 'package:flutter/material.dart';

import '../app_colors.dart';

/// The Interna logo face, drawn in code so the eyes can blink.
///
/// It replaces `assets/images/main_logo.png` on the splash screen. The numbers
/// below are not guesses: they were measured from that PNG and from the
/// designer's blink video, and both agreed. Every value is a fraction of
/// [size], so the face keeps its shape at any size.
///
/// Only the eyes move. The mouth never changes, same as the video.
class BlinkingFace extends StatefulWidget {
  /// Width and height of the square the face is drawn inside.
  final double size;

  /// Colour of the eyes and mouth. The logo file uses #0D0140, which is
  /// AppColors.heading, so that is the default.
  final Color color;

  const BlinkingFace({
    super.key,
    required this.size,
    this.color = AppColors.heading,
  });

  @override
  State<BlinkingFace> createState() => _BlinkingFaceState();
}

class _BlinkingFaceState extends State<BlinkingFace>
    with SingleTickerProviderStateMixin {
  // --- Shape, measured from the logo file (as a fraction of size) ----------

  /// Eye diameter when the eye is fully open.
  static const double _eyeOpenSize = 0.17;

  /// A closed eye is a short flat line, not a dot.
  static const double _eyeClosedWidth = 0.136;
  static const double _eyeClosedHeight = 0.019;

  /// Where the middle of each eye sits.
  static const double _leftEyeCentreX = 0.30;
  static const double _rightEyeCentreX = 0.685;
  static const double _eyeCentreY = 0.43;

  /// The mouth. Its height is exactly half its width, which is what makes it
  /// a true half circle.
  static const double _mouthWidth = 0.205;
  static const double _mouthTopY = 0.632;

  late final AnimationController _controller;

  /// 0.0 = eyes shut, 1.0 = eyes fully open. Everything in between is drawn.
  late final Animation<double> _eyeOpen;

  @override
  void initState() {
    super.initState();

    // The splash screen leaves after 2600 ms, so the whole blink has to
    // finish before that.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // A TweenSequence is a list of steps played one after the other.
    // `weight` is how long each step lasts. We used milliseconds as the
    // weights so the list reads like a timeline: 450 + 330 + ... = 2400.
    _eyeOpen = TweenSequence<double>([
      // Start shut, so the eyes opening is the first thing the user sees.
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 450),
      // Open. 330 ms is the same speed as the designer's video.
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 330,
      ),
      // Stay open for a moment.
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 770),
      // One quick blink: shut...
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 150,
      ),
      // ...and open again.
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 150,
      ),
      // Stay open until the screen goes away.
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 550),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    // The controller keeps ticking until we stop it, so it must be cleaned up.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _eyeOpen,
        builder: (BuildContext context, Widget? child) {
          final double t = _eyeOpen.value;

          // One shape does both eye states.
          //   t = 0 -> wide and 1 pixel tall, so a flat line
          //   t = 1 -> width equals height, so a circle
          // The corner radius is always half the height, so the shape is a
          // rounded line while it is short and a perfect circle when it is
          // as tall as it is wide.
          final double eyeWidth =
              (_eyeClosedWidth + (_eyeOpenSize - _eyeClosedWidth) * t) * s;
          final double eyeHeight =
              (_eyeClosedHeight + (_eyeOpenSize - _eyeClosedHeight) * t) * s;

          return Stack(
            children: [
              _buildEye(
                centreX: _leftEyeCentreX * s,
                width: eyeWidth,
                height: eyeHeight,
              ),
              _buildEye(
                centreX: _rightEyeCentreX * s,
                width: eyeWidth,
                height: eyeHeight,
              ),
              _buildMouth(s),
            ],
          );
        },
      ),
    );
  }

  /// One eye. `centreX` is the middle of the eye, so the shape grows and
  /// shrinks around its own centre instead of sliding sideways.
  Widget _buildEye({
    required double centreX,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: centreX - width / 2,
      top: _eyeCentreY * widget.size - height / 2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  /// The smile: a rectangle whose bottom two corners are fully rounded.
  /// Because the height is half the width, those corners meet and the shape
  /// becomes a half circle.
  Widget _buildMouth(double s) {
    final double width = _mouthWidth * s;
    final double height = width / 2;

    return Positioned(
      left: s / 2 - width / 2,
      top: _mouthTopY * s,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(width / 2),
          ),
        ),
      ),
    );
  }
}
