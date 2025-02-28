import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomLabelPainter extends CustomPainter {
  final ui.Image qrImage; // Pre-generated QR code image
  final String inventoryCode;
  final String? description1;
  final String? description2;
  final String? description3;

  CustomLabelPainter({
    required this.qrImage,
    required this.inventoryCode,
    this.description1,
    this.description2,
    this.description3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background
    final Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw QR Code
    canvas.drawImage(
      qrImage,
      Offset(20, 0),
      Paint(),
    );

    // Draw Inventory Code and Description
    final textStyle = TextStyle(
      fontSize: 22, // Slightly bigger for better visibility
      fontWeight: FontWeight.w900, // Maximum boldness
      color: Colors.black,
    );

    final textSpan = TextSpan(
        text: '$inventoryCode\n$description1\n$description2\n$description3',
        style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width / 2);

    final textOffset = Offset(qrImage.width + 30, 0);

    // final textOffset =
    //     Offset(qrImage.width + 10, (size.height - textPainter.height) / 2);

    // final textOffset =
    //     Offset(size.width * 0.35, (size.height - textPainter.height) / 2);

    // final textOffset =
    //     Offset(size.width * 0.35, (size.height - textPainter.height) / 2);

    // final textOffset =
    //     Offset(size.width / 2, (size.height - textPainter.height) / 2);

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomLabelPainter oldDelegate) => false;

  Future<ui.Image> toImage(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);
    paint(canvas, size);
    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}
