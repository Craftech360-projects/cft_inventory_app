import 'dart:developer';
import 'dart:ui' as ui;

import 'package:app/ui/custom_label_for_cards.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

Future<void> printLabelFromCard(
    Map<String, String> item, BuildContext context) async {
  try {
    bool isConnected = await SunmiPrinter.bindingPrinter() ?? false;
    if (!isConnected) {
      throw Exception('Printer not connected');
    }

    final image = await generateLabelImage(
        item['sku'] ?? '',
        item['product_name'] ?? '',
        item['category'] ?? '',
        item['sub_category'] ?? '',
        item['description'] ?? ''
        // item['description4'] ?? '',
        );

    // Convert the image to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageData = byteData!.buffer.asUint8List();

    // Print the image
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.printImage(imageData);
    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.exitTransactionPrint(true);

    // ✅ Show Snackbar Instead of Voice Notification
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Printing Completed ✅"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } on Exception catch (e) {
    log('Error printing: $e');

    // ✅ Show Snackbar on Error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

Future<ui.Image> generateLabelImage(
  String sku,
  String productName,
  String category,
  String subCategory,
  String description,
) async {
  // Generate QR code image
  final qrPainter = QrPainter(
    data: sku, // Use SKU as QR data
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

  // Create the custom label painter with updated parameters
  final painter = CustomLabelPainterCard(
    qrImage: qrBitmap,
    sku: sku, // Pass SKU directly
    productName: productName,
    description: description,
  );

  // Dimensions of the label (50mm x 30mm)
  const double labelWidth = 600; // Approximate pixels for 50mm
  return await painter.toImage(labelWidth, labelHeight);
}
