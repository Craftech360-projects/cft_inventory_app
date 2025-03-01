// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';

// class CustomLabelPainterCard extends CustomPainter {
//   final ui.Image qrImage;
//   final String productName;
//   final String? category;
//   final String? subCategory;
//   final String? description;
//   // final String? description4;

//   CustomLabelPainterCard({
//     required this.qrImage,
//     required this.productName,
//     this.category,
//     this.subCategory,
//     this.description,
//     // this.description4,
//   });

//   // Extract Purpose and User from description
//   Map<String, String?> _extractAdditionalInfo() {
//     if (description == null ||
//         !description!.contains('Additional Information:')) {
//       return {'purpose': null, 'user': null};
//     }

//     String? purpose;
//     String? user;

//     // Extract purpose
//     final purposeRegex = RegExp(r'Purpose\s*:\s*(.*?)(?:\n|$)');
//     final purposeMatch = purposeRegex.firstMatch(description!);
//     if (purposeMatch != null && purposeMatch.groupCount >= 1) {
//       purpose = purposeMatch.group(1)?.trim();
//     }

//     // Extract user
//     final userRegex = RegExp(r'user\s*:\s*(.*?)(?:\n|$)');
//     final userMatch = userRegex.firstMatch(description!);
//     if (userMatch != null && userMatch.groupCount >= 1) {
//       user = userMatch.group(1)?.trim();
//     }

//     return {'purpose': purpose, 'user': user};
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint backgroundPaint = Paint()..color = Colors.white;
//     canvas.drawRect(
//         Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

//     canvas.drawImage(
//       qrImage,
//       const Offset(10, 0),
//       Paint(),
//     );

//     // Draw Inventory Code and Description
//     const textStyle = TextStyle(
//       fontSize: 20,
//       fontWeight: FontWeight.w900,
//       color: Colors.black,
//     );

//     // Process description to include only the first part
//     final String rawProcessedDescription = description != null
//         ? description!.split('\n\nAdditional Information:')[0].trim()
//         : '';

//     // Extract purpose and user
//     final additionalInfo = _extractAdditionalInfo();
//     final purpose = additionalInfo['purpose'];
//     final user = additionalInfo['user'];

//     // Format the processed description with line breaks
//     final String processedDescription =
//         _formatLongText(rawProcessedDescription, 20);

//     // Build the text to display
//     String displayText = productName;
//     if (purpose != null && purpose.isNotEmpty) {
//       displayText += '\nPurpose: $purpose';
//     }
//     if (user != null && user.isNotEmpty) {
//       displayText += '\nUser: $user';
//     }
//     if (processedDescription.isNotEmpty) {
//       displayText += '\n$processedDescription';
//     }

//     final textSpan = TextSpan(text: displayText, style: textStyle);

//     final textPainter = TextPainter(
//       text: textSpan,
//       textAlign: TextAlign.left,
//       textDirection: TextDirection.ltr,
//     );

//     textPainter.layout(maxWidth: size.width / 2);

//     final textOffset = Offset(qrImage.width + 30, 0);
//     textPainter.paint(canvas, textOffset);
//   }

// // Helper method to format long text with line breaks
//   String _formatLongText(String text, int charsPerLine) {
//     if (text.length <= charsPerLine) {
//       return text;
//     }

//     final buffer = StringBuffer();
//     int currentPosition = 0;

//     while (currentPosition < text.length) {
//       // Determine the end of this line
//       int endPosition = currentPosition + charsPerLine;

//       if (endPosition >= text.length) {
//         // If this is the last piece, just add it
//         buffer.write(text.substring(currentPosition));
//         break;
//       } else {
//         // Find last space within the character limit
//         int lastSpacePosition =
//             text.substring(currentPosition, endPosition).lastIndexOf(' ');

//         if (lastSpacePosition == -1) {
//           // No space found, just break at the character limit
//           buffer.write(text.substring(currentPosition, endPosition));
//           buffer.write('\n');
//           currentPosition = endPosition;
//         } else {
//           // Break at the last space
//           int breakPosition = currentPosition + lastSpacePosition;
//           buffer.write(text.substring(currentPosition, breakPosition));
//           buffer.write('\n');
//           currentPosition = breakPosition + 1; // +1 to skip the space
//         }
//       }
//     }

//     return buffer.toString();
//   }

//   @override
//   bool shouldRepaint(CustomLabelPainterCard oldDelegate) => false;

//   Future<ui.Image> toImage(double width, double height) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final size = Size(width, height);
//     paint(canvas, size);
//     final picture = recorder.endRecording();
//     return await picture.toImage(width.toInt(), height.toInt());
//   }
// }

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomLabelPainterCard extends CustomPainter {
  final ui.Image qrImage;
  final String sku;
  final String productName;
  final String? description;

  CustomLabelPainterCard({
    required this.qrImage,
    required this.sku,
    required this.productName,
    this.description,
  });

  // Extract additional information from description
  Map<String, String?> _extractAdditionalInfo() {
    if (description == null ||
        !description!.contains('Additional Information:')) {
      return {'purpose': null, 'user': null, 'sn_id_imei_mac': null};
    }

    String? purpose;
    String? user;
    String? snIdImeiMac;

    // Extract purpose
    final purposeRegex = RegExp(r'Purpose\s*:\s*(.*?)(?:\n|$)');
    final purposeMatch = purposeRegex.firstMatch(description!);
    if (purposeMatch != null && purposeMatch.groupCount >= 1) {
      purpose = purposeMatch.group(1)?.trim();
    }

    // Extract user
    final userRegex = RegExp(r'user\s*:\s*(.*?)(?:\n|$)');
    final userMatch = userRegex.firstMatch(description!);
    if (userMatch != null && userMatch.groupCount >= 1) {
      user = userMatch.group(1)?.trim();
    }

    // Extract SN ID/IMEI/Mac
    final snRegex = RegExp(r'SN ID\/\s*IMEI\s*\/Mac\s*:\s*(.*?)(?:\n|$)');
    final snMatch = snRegex.firstMatch(description!);
    if (snMatch != null && snMatch.groupCount >= 1) {
      snIdImeiMac = snMatch.group(1)?.trim();
    }

    return {'purpose': purpose, 'user': user, 'sn_id_imei_mac': snIdImeiMac};
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw QR code at the left top corner
    canvas.drawImage(
      qrImage,
      Offset(10, 0),
      Paint(),
    );

    // Draw main content on the right side
    const mainTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );

    // Process description to include only the first part
    final String rawProcessedDescription = description != null
        ? description!.split('\n\nAdditional Information:')[0].trim()
        : '';

    // Extract additional information
    final additionalInfo = _extractAdditionalInfo();
    final purpose = additionalInfo['purpose'];
    final user = additionalInfo['user'];
    final snIdImeiMac = additionalInfo['sn_id_imei_mac'];

    // Format the processed description with line breaks
    final String processedDescription =
        _formatLongText(rawProcessedDescription, 20);

    // Build the text to display - start with SKU at the top
    String displayText = sku;

    // Add product name
    displayText += "\n$productName";

    if (processedDescription.isNotEmpty) {
      displayText += '\n$processedDescription';
    }

    if (snIdImeiMac != null && snIdImeiMac.isNotEmpty) {
      displayText += '\n$snIdImeiMac';
    }

    if ((user != null && user.isNotEmpty) ||
        (purpose != null && purpose.isNotEmpty)) {
      String purposeAndUser = "";

      if (purpose != null && purpose.isNotEmpty) {
        purposeAndUser = purpose;
      }
      if (user != null && user.isNotEmpty) {
        if (purposeAndUser.isNotEmpty) {
          purposeAndUser += " / ";
        }
        purposeAndUser += user;
      }
      displayText += '\n$purposeAndUser';
    }

    final textSpan = TextSpan(text: displayText, style: mainTextStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width - qrImage.width - 50);

    // Align the right-side text with the top of the label (same top padding)
    final textOffset = Offset(qrImage.width + 30, 0);
    textPainter.paint(canvas, textOffset);
  }

  // Helper method to format long text with line breaks
  String _formatLongText(String text, int charsPerLine) {
    if (text.length <= charsPerLine) {
      return text;
    }

    final buffer = StringBuffer();
    int currentPosition = 0;

    while (currentPosition < text.length) {
      // Determine the end of this line
      int endPosition = currentPosition + charsPerLine;

      if (endPosition >= text.length) {
        // If this is the last piece, just add it
        buffer.write(text.substring(currentPosition));
        break;
      } else {
        // Find last space within the character limit
        int lastSpacePosition =
            text.substring(currentPosition, endPosition).lastIndexOf(' ');

        if (lastSpacePosition == -1) {
          // No space found, just break at the character limit
          buffer.write(text.substring(currentPosition, endPosition));
          buffer.write('\n');
          currentPosition = endPosition;
        } else {
          // Break at the last space
          int breakPosition = currentPosition + lastSpacePosition;
          buffer.write(text.substring(currentPosition, breakPosition));
          buffer.write('\n');
          currentPosition = breakPosition + 1; // +1 to skip the space
        }
      }
    }

    return buffer.toString();
  }

  @override
  bool shouldRepaint(CustomLabelPainterCard oldDelegate) => false;

  Future<ui.Image> toImage(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);
    paint(canvas, size);
    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}
