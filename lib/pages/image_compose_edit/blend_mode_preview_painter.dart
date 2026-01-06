import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BlendModePreviewPainter extends CustomPainter {
  final ui.Image foregroundImage;
  final ui.Image? backgroundImage;
  final BlendMode blendMode;

  BlendModePreviewPainter({
    required this.foregroundImage,
    this.backgroundImage,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = blendMode;
    canvas.drawImageRect(
      foregroundImage,
      Rect.fromLTWH(0, 0, foregroundImage.width.toDouble(), foregroundImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BlendModePreviewPainter oldDelegate) {
    return oldDelegate.foregroundImage != foregroundImage ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.blendMode != blendMode;
  }
}

