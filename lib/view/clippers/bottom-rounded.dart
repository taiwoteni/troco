import 'package:flutter/material.dart';

class BottomRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    Offset start = Offset(0, size.height * 0.9);
    Offset control1 = Offset(size.width / 2, size.height + 20);
    Offset end = Offset(size.width, size.height * 0.9);

    path.lineTo(start.dx, start.dy);
    path.quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
