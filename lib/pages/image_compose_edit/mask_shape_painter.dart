import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MaskShapePainter extends CustomPainter {
  final String maskType;

  MaskShapePainter({required this.maskType});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    
    final isFeather = maskType.startsWith('feather');
    final isHalfFeather = maskType.startsWith('halfFeather');
    final isSolid = maskType.startsWith('solid');
    
    final isSquare = maskType.contains('Square');
    final isTriangle = maskType.contains('Triangle');
    final isCircle = maskType.contains('Circle');
    final isHexagon = maskType.contains('Hexagon');
    
    if (maskType == 'none') {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
        paint,
      );
      return;
    }
    
    Path path;
    if (isSquare) {
      path = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
          const Radius.circular(8),
        ));
    } else if (isTriangle) {
      path = Path();
      final height = radius * math.sqrt(3);
      path.moveTo(center.dx, center.dy - height * 2 / 3);
      path.lineTo(center.dx - radius, center.dy + height / 3);
      path.lineTo(center.dx + radius, center.dy + height / 3);
      path.close();
    } else if (isCircle) {
      path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
    } else if (isHexagon) {
      path = _createHexagonPath(center, radius);
    } else {
      path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    
    if (isSolid) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    } else if (isHalfFeather) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      
      final solidPath = Path();
      if (isSquare) {
        solidPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(center.dx - radius, center.dy - radius, radius * 2, radius),
          const Radius.circular(8),
        ));
      } else if (isTriangle) {
        solidPath.addPath(path, Offset.zero);
        solidPath.addRect(Rect.fromLTWH(0, center.dy, size.width, size.height));
      } else if (isCircle) {
        solidPath.addOval(Rect.fromLTWH(
          center.dx - radius,
          center.dy - radius,
          radius * 2,
          radius,
        ));
      } else if (isHexagon) {
        solidPath.addPath(path, Offset.zero);
        solidPath.addRect(Rect.fromLTWH(0, center.dy, size.width, size.height));
      }
      
      final solidPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(solidPath, solidPaint);
      
      final gradientPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx, center.dy),
          Offset(center.dx, center.dy + radius),
          [
            Colors.white,
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
          [0.0, 0.5, 1.0],
        )
        ..style = PaintingStyle.fill;
      
      final gradientPath = Path();
      if (isSquare) {
        gradientPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(center.dx - radius, center.dy, radius * 2, radius),
          const Radius.circular(8),
        ));
      } else if (isCircle) {
        gradientPath.addOval(Rect.fromLTWH(
          center.dx - radius,
          center.dy,
          radius * 2,
          radius,
        ));
      } else {
        gradientPath.addPath(path, Offset.zero);
        gradientPath.addRect(Rect.fromLTWH(0, 0, size.width, center.dy));
      }
      
      canvas.drawPath(gradientPath, gradientPaint);
      canvas.restore();
    } else if (isFeather) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      
      final gradientPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            Colors.white,
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.0),
          ],
          [0.0, 0.5, 0.8, 1.0],
        )
        ..style = PaintingStyle.fill;
      
      final innerRadius = radius * 0.7;
      Path innerPath;
      if (isSquare) {
        innerPath = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: innerRadius * 2, height: innerRadius * 2),
            const Radius.circular(8),
          ));
      } else if (isTriangle) {
        innerPath = Path();
        final height = innerRadius * math.sqrt(3);
        innerPath.moveTo(center.dx, center.dy - height * 2 / 3);
        innerPath.lineTo(center.dx - innerRadius, center.dy + height / 3);
        innerPath.lineTo(center.dx + innerRadius, center.dy + height / 3);
        innerPath.close();
      } else if (isCircle) {
        innerPath = Path()
          ..addOval(Rect.fromCircle(center: center, radius: innerRadius));
      } else if (isHexagon) {
        innerPath = _createHexagonPath(center, innerRadius);
      } else {
        innerPath = path;
      }
      
      final solidPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(innerPath, solidPaint);
      
      canvas.drawPath(path, gradientPaint);
      canvas.restore();
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
  bool shouldRepaint(covariant MaskShapePainter oldDelegate) {
    return oldDelegate.maskType != maskType;
  }
}

