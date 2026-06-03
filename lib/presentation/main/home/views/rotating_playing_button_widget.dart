import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RotatingPlayButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const RotatingPlayButton({super.key, required this.onTap, this.size = 130});

  @override
  State<RotatingPlayButton> createState() => _RotatingPlayButtonState();
}

class _RotatingPlayButtonState extends State<RotatingPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(); // Infinite rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: widget.size.sp,
        width: widget.size.sp,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // // ✨ Blur effect background (glassmorphism style)
            // ClipOval(
            //   child: BackdropFilter(
            //     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            //     child: Container(
            //       color: Colors.white.withOpacity(0.15),
            //     ),
            //   ),
            // ),

            // 🔄 Rotating Text Ring
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _controller.value * 6.3, // full circular rotation
                  child: child,
                );
              },
              child: CustomPaint(
                painter: _CircularTextPainter(
                  text: "  PLAY VIDEO  PLAY VIDEO  PLAY VIDEO  ",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontFamily: 'headline',
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Container(),
              ),
            ),

            // ▶ Center Play Icon with blurred background
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7.44, sigmaY: 7.44),
                child: Container(
                  height: (widget.size * 0.52).sp,
                  width: (widget.size * 0.52).sp,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_sharp, size: (widget.size * 0.35).sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 Custom circular text painter
class _CircularTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;

  _CircularTextPainter({
    required this.text,
    this.style = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      fontFamily: 'headline',
      color: Colors.white,
    ),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2.7;
    final textChars = text.split('');
    final angleStep = (2 * 3.14) / textChars.length;

    for (int i = 0; i < textChars.length; i++) {
      final angle = i * angleStep;
      final x = radius * cos(angle) + size.width / 2;
      final y = radius * sin(angle) + size.height / 2;

      final painter = TextPainter(
        text: TextSpan(text: textChars[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();

      canvas.translate(x, y);
      canvas.rotate(angle + 1.57); // rotate to face outward
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
