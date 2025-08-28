import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final double _confidence;
  final List<dynamic> recognitions;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter(
    this.recognitions,
    this.imageWidth,
    this.imageHeight,
    this._confidence,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Scale factors to adapt to the actual widget size
    double scaleX = size.width / imageWidth;
    double scaleY = size.height / imageHeight;

    for (var recognition in recognitions) {
      // Normalize bounding box coordinates
      double x = recognition['rect']['x'] * imageWidth * scaleX;
      double y = recognition['rect']['y'] * imageHeight * scaleY;
      double w = recognition['rect']['w'] * imageWidth * scaleX;
      double h = recognition['rect']['h'] * imageHeight * scaleY;

      Rect rect = Rect.fromLTWH(x, y, w, h);

      if (recognition['confidenceInClass'] >= _confidence) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );

        // Display the detected class label above the bounding box
        TextSpan span = TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            backgroundColor: Colors.red,
          ),
          text: recognition['detectedClass'],
        );
        TextPainter textPainter = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}