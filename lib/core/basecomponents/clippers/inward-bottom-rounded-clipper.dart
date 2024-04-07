import 'package:flutter/material.dart';
import 'package:troco/core/app/size-manager.dart';

class InwardBottomRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    Offset start = Offset(0, size.height);
    Offset control1 = Offset(size.width / 2, size.height - SizeManager.large);
    Offset end = Offset(size.width, size.height);

    path.lineTo(start.dx, start.dy);
    path.quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
