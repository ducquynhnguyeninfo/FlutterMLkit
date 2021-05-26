// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;
import 'dart:math' as Math;

import 'package:google_ml_kit/google_ml_kit.dart';

class SmilePainterCamera extends CustomPainter {
  final Size imageSize;
  final List<Face> faces;

  SmilePainterCamera(this.imageSize, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellow;

    for (var i = 0; i < faces.length; i++) {
      final rect = _scaleRect(
        rect: faces[i].boundingBox,
        imageSize: imageSize,
        widgetSize: size,
      );

      drawSmile(canvas, rect, paint);
    }
  }

  void drawSmile(Canvas canvas, Rect rect, Paint paint) {
    final radius = Math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius / 8;

    canvas.drawRect(rect, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawCircle(center, radius, paint);
    canvas.drawArc(
        Rect.fromCircle(
            center: center.translate(0, radius / 8), radius: radius / 2),
        0,
        Math.pi,
        false,
        smilePaint);

    // eyes
    canvas.drawCircle(Offset(center.dx - radius / 2, center.dy - radius / 2),
        radius / 8, Paint());

    canvas.drawCircle(Offset(center.dx + radius / 2, center.dy - radius / 2),
        radius / 8, Paint());
  }

  @override
  bool shouldRepaint(covariant SmilePainterCamera oldDelegate) {
    return imageSize != oldDelegate.imageSize || faces != oldDelegate.faces;
  }

  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left.toDouble() * scaleX,
      rect.top.toDouble() * scaleY,
      rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY,
    );
  }
}
