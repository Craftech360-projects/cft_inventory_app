import 'dart:developer';
import 'dart:ui' as ui;

import 'package:app/ui/custom_label.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

Future<void> printLabel(String qrData, String inventoryCode,
    String? description1, String? description2, String? description3) async {
  try {
    bool isConnected = false;
    try {
      isConnected = await SunmiPrinter.bindingPrinter() ?? false;
    } catch (e) {
      log('Failed to bind printer: $e');
    }

    if (!isConnected) {
      throw Exception('Printer not connected');
    }

    // Generate the label image
    final image = await generateLabelImage(qrData, inventoryCode,
        description1 ?? '', description2 ?? '', description3 ?? '');

    // Convert the image to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageData = byteData!.buffer.asUint8List();

    // Print the image
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.printImage(imageData);
    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.exitTransactionPrint(true);
  } catch (e) {
    log('Error printing: $e');
    rethrow;
  }
}

Future<ui.Image> generateLabelImage(String qrData, String inventoryCode,
    String? description1, String? description2, String? description3) async {
  // Generate QR code image
  final qrPainter = QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  );

  // Set the QR code size to fit within the label height (30mm)
  const double labelHeight = 175; // Approximate pixels for 30mm
  const double maxQrSize = labelHeight * 0.7; // 80% of the label height

  final qrImage = await qrPainter.toImageData(maxQrSize);
  final qrBitmap = await decodeImageFromList(qrImage!.buffer.asUint8List());

  // Create the custom label painter
  final painter = CustomLabelPainter(
    qrImage: qrBitmap,
    inventoryCode: inventoryCode,
    description1: description1,
    description2: description2,
    description3: description3,
  );
// Dimensions of the label (50mm x 30mm)
  const double labelWidth = 600; // Approximate pixels for 50mm
  return await painter.toImage(labelWidth, labelHeight);
}
