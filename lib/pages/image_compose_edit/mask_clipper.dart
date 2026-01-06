import 'dart:math' as math;
import 'package:flutter/material.dart';

class MaskClipper extends CustomClipper<Path> {
  final String maskType;
  final Size size;

  MaskClipper({required this.maskType, required this.size});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    switch (maskType) {
      case 'featherSquare':
      case 'halfFeatherSquare':
      case 'solidSquare':
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
            const Radius.circular(8),
          ));
      
      case 'featherTriangle':
      case 'halfFeatherTriangle':
      case 'solidTriangle':
        final path = Path();
        final height = radius * math.sqrt(3);
        path.moveTo(center.dx, center.dy - height * 2 / 3);
        path.lineTo(center.dx - radius, center.dy + height / 3);
        path.lineTo(center.dx + radius, center.dy + height / 3);
        path.close();
        return path;
      
      case 'featherCircle':
      case 'halfFeatherCircle':
      case 'solidCircle':
        return Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius));
      
      case 'featherHexagon':
      case 'halfFeatherHexagon':
      case 'solidHexagon':
        return _createHexagonPath(center, radius);
      
      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(MaskClipper oldClipper) {
    return oldClipper.maskType != maskType || oldClipper.size != size;
  }
}

