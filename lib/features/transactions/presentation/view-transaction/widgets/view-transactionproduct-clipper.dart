import 'package:flutter/material.dart';

// import '../../../../../core/app/size-manager.dart';

class TransactionProductClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cornerRadius = 20.0; // Adjust the corner radius as needed
    final double curveHeight = 40.0; // Adjust the curve height as needed

    path.lineTo(0, size.height - cornerRadius); // Start from bottom-left
    path.quadraticBezierTo(size.width / 4, size.height - curveHeight,
        size.width / 2, size.height - cornerRadius); // Curve to bottom-center
    path.quadraticBezierTo(size.width * 3 / 4, size.height, size.width,
        size.height - cornerRadius); // Curve to bottom-right
    path.lineTo(size.width, 0); // Line to top-right
    path.lineTo(0, 0); // Line to top-left
    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
