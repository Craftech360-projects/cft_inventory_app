import 'dart:developer';
import 'dart:ui' as ui;

import 'package:app/ui/custom_label_for_inputs.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

Future<void> printLabelFromInputs(
  String inventoryCode,
  String product,
  String? description1,
  String? description2,
  String? description3,
  String? description4,
  BuildContext context,
) async {
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
    final image = await generateLabelImage(
      inventoryCode,
      product,
      description1 ?? '',
      description2 ?? '',
      description3 ?? '',
      description4 ?? '',
    );

    // Convert the image to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageData = byteData!.buffer.asUint8List();

    // Print the image
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.printImage(imageData);
    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.exitTransactionPrint(true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Printing Completed ✅"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    log('Error printing: $e');
    rethrow;
  }
}

Future<ui.Image> generateLabelImage(
  String inventoryCode,
  String product,
  String? ramAndGraphics,
  String? serialNumber,
  String? purposeAndUser,
  String? additionalInfo,
) async {
  // Generate QR code image

  final qrPainter = QrPainter(
    data: inventoryCode,
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

  const double labelHeight = 175;
  const double maxQrSize = labelHeight * 0.7;

  final qrImage = await qrPainter.toImageData(maxQrSize);
  final qrBitmap = await decodeImageFromList(qrImage!.buffer.asUint8List());

  // Create the custom label painter
  final painter = CustomLabelPainterInputs(
      qrImage: qrBitmap,
      inventoryCode: inventoryCode,
      product: product,
      ramAndGraphics: ramAndGraphics,
      serialNumber: serialNumber,
      purposeAndUser: purposeAndUser,
      additionalInfo: additionalInfo,
      );

  const double labelWidth = 600;
  return await painter.toImage(labelWidth, labelHeight);
}
