import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeaderNetwork extends StatelessWidget {
  const HeaderNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _NetworkPainter()),
          Align(
            alignment: const Alignment(0, -0.12),
            child: Container(
              width: 142,
              height: 142,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: const [
                  BoxShadow(color: Color(0x88FF3E9D), blurRadius: 36, spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset('assets/images/pinka_logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(19);
    final line = Paint()..color = const Color(0x352E4090)..strokeWidth = 1.2;
    final dot = Paint()..color = const Color(0xFF6068D8);
    final glow = Paint()..color = const Color(0x254A4FEA);
    final pts = <Offset>[];
    for (var i = 0; i < 24; i++) {
      pts.add(Offset(18 + random.nextDouble() * (size.width - 36), 18 + random.nextDouble() * (size.height - 35)));
    }
    for (var i = 0; i < pts.length - 1; i++) {
      if (i.isEven) canvas.drawLine(pts[i], pts[i + 1], line);
      canvas.drawCircle(pts[i], 8, glow);
      canvas.drawCircle(pts[i], 3.5, dot);
    }
    final accent = Paint()..color = const Color(0x55FF3E9D)..strokeWidth = 2;
    canvas.drawLine(Offset(size.width * .34, size.height * .84), Offset(size.width * .66, size.height * .84), accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
