import 'package:flutter/material.dart';

class CheckerboardPainter extends CustomPainter {
  //  A CustomPainter class that paints a checkerboard pattern.

  final Color color1; // Color of the first square
  final Color color2; // Color of the second square
  final double squareSize;

  CheckerboardPainter({
    this.color1 = Colors.black, // Default black
    this.color2 = Colors.white, // Default white
    this.squareSize = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //size is the size of the area we are painting on.
    final double squareWidth = squareSize;
    final double squareHeight = squareSize;

    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    // Calculate the number of rows and columns needed to fill the size
    final int rows = (size.height / squareHeight).ceil();
    final int cols = (size.width / squareWidth).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final double x = col * squareWidth;
        final double y = row * squareHeight;
        final Rect squareRect = Rect.fromLTWH(x, y, squareWidth, squareHeight);
        // Alternate colors for each square
        canvas.drawRect(squareRect, (row + col) % 2 == 0 ? paint1 : paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //  Should return true if the painter needs to repaint (e.g., if the rows, cols, or colors change).
    if (oldDelegate is CheckerboardPainter) {
      return oldDelegate.color1 != color1 ||
          oldDelegate.color2 != color2 ||
          oldDelegate.squareSize != squareSize;
    }
    return true; //repaint
  }
}

/// Example usage in a widget:
class CheckerboardWidget extends StatelessWidget {
  const CheckerboardWidget(
      {super.key, this.color1, this.color2, this.squareSize});
  final Color? color1;
  final Color? color2;
  final double? squareSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        painter: CheckerboardPainter(
          color1: color1 ?? Colors.black,
          color2: color2 ?? Colors.transparent,
          squareSize: squareSize ?? 10,
        ),
      );

      // return Center(
      //   child: SizedBox(
      //     width: constraints.maxWidth, // Use available width
      //     height: constraints.maxHeight, // Use available height
      //     child: CustomPaint(
      //       painter: CheckerboardPainter(
      //         color1: color1 ?? Colors.black,
      //         color2: color2 ?? Colors.white,
      //         squareSize: squareSize ?? 10,
      //       ),
      //     ),
      //   ),
      // );
    });
  }
}

// void main() {
//   runApp(
//     const MaterialApp(
//       home: Scaffold(
//         body: CheckerboardWidget(), // Use the widget
//       ),
//     ),
//   );
// }
