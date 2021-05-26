import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;
import 'dart:math' as Math;

import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPaint {
  final CustomPainter painter;

  FacePainter(this.painter) : super(painter: painter);
}

class SmilePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  SmilePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }

    final paintRectStyle = Paint()
      ..color = Colors.red
      ..strokeWidth = 30.0
      ..style = PaintingStyle.stroke;

    // Draw body
    final paint = Paint()..color = Colors.yellow;

    for (var i = 0; i < faces.length; i++) {
      drawSmile(canvas, faces[i].boundingBox, paint);
    }
  }

  void drawSmile(Canvas canvas, Rect rect, Paint paint) {
    final radius = Math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius / 8;

    canvas.drawRect(rect, paint);
    canvas.drawCircle(center, radius, paint);
    canvas.drawArc(
        Rect.fromCircle(
            center: center.translate(0, radius / 8), radius: radius / 2),
        0,
        Math.pi,
        false,
        smilePaint);

    // eyes
    canvas.drawCircle(Offset((center.dx - radius) / 2, center.dy - radius / 2),
        radius / 8, Paint());

    canvas.drawCircle(Offset((center.dx + radius) / 2, center.dy - radius / 2),
        radius / 8, Paint());
  }

  @override
  bool shouldRepaint(covariant SmilePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
