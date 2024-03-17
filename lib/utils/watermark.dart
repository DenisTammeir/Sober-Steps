import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Import the dart:ui library with an alias

class WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.purple
          .withOpacity(0.2), // Set your watermark text color and opacity
      fontSize: 16.0,
    );

    final textSpan = TextSpan(
      text: '#itakesobersteps',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();

    final double stepX = 130.0;
    final double stepY = 20.0;

    for (double y = 0; y < size.height; y += stepY) {
      for (double x = 0; x < size.width; x += stepX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
