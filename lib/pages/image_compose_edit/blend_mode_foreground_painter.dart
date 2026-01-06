import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BlendModeForegroundPainter extends CustomPainter {
  final ui.Image foregroundImage;
  final ui.Image? backgroundImage;
  final BlendMode blendMode;

  BlendModeForegroundPainter({
    required this.foregroundImage,
    this.backgroundImage,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final paint = Paint()..blendMode = blendMode;
    canvas.drawImageRect(
      foregroundImage,
      Rect.fromLTWH(0, 0, foregroundImage.width.toDouble(), foregroundImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BlendModeForegroundPainter oldDelegate) {
    return oldDelegate.foregroundImage != foregroundImage ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.blendMode != blendMode;
  }
}

