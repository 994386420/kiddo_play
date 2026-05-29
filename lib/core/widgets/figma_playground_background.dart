import 'package:flutter/material.dart';

class FigmaPlaygroundBackground extends StatelessWidget {
  const FigmaPlaygroundBackground({
    required this.child,
    this.backgroundColor = const Color(0xFFFFF9F5),
    super.key,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: backgroundColor),
        const Positioned.fill(
          child: CustomPaint(
            painter: _FigmaDotPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _FigmaDotPainter extends CustomPainter {
  const _FigmaDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = const Color(0x80FFA0C8);
    final blue = Paint()..color = const Color(0x738CBEFF);
    final yellow = Paint()..color = const Color(0x73FFDC64);
    const spacing = 36.0;

    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, pink);
        canvas.drawCircle(Offset(x + 18, y + 18), 2.0, blue);
        canvas.drawCircle(Offset(x + 9, y + 27), 2.0, yellow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
