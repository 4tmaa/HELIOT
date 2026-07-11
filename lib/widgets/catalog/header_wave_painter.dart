import 'package:flutter/material.dart';

class HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    paint.color = const Color(0xFFD92027);
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = const Color(0xFFB01A20);
    final path1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 1.1, size.width * 0.7, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.2, size.width, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, paint);

    paint.color = Colors.white.withOpacity(0.12);
    final path2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.05, size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.7, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}