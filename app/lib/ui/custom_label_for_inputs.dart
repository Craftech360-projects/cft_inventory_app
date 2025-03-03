import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomLabelPainterInputs extends CustomPainter {
  final ui.Image qrImage;
  final String inventoryCode;
  final String product;
  final String? ramAndGraphics;
  final String? serialNumber;
  final String? purposeAndUser;
  final String? additionalInfo;

  CustomLabelPainterInputs({
    required this.qrImage,
    required this.product,
    required this.inventoryCode,
    required this.ramAndGraphics,
    required this.serialNumber,
    required this.purposeAndUser,
    required this.additionalInfo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    canvas.drawImage(
      qrImage,
      Offset(10, 0),
      Paint(),
    );

    // Draw Inventory Code and Description
    final textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );

    final textSpan = TextSpan(
        text:
            '$inventoryCode\n$product\n${ramAndGraphics ?? ''}\n${serialNumber ?? ''}\n${purposeAndUser ?? ''}\n${additionalInfo ?? ''}',
        style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width / 2);

    final textOffset = Offset(qrImage.width + 30, 0);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomLabelPainterInputs oldDelegate) => false;

  Future<ui.Image> toImage(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);
    paint(canvas, size);
    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}
