import 'package:flutter/material.dart';

// Dashed rounded placeholder box (Flutter has no built-in dashed border)
class DashedBox extends StatelessWidget {
  final String text;
  final double height;
  final VoidCallback? onTap;
  const DashedBox({super.key, required this.text, this.height = 100, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedPainter(),
        child: Container(
          width: double.infinity,
          height: height,
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6A7776))),
        ),
      ),
    );
  }
}

// Draws the dashes along a rounded rectangle
class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB5C2BF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}