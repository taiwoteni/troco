import 'package:flutter/cupertino.dart';

class SettingsHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    Path path = Path();

    path.lineTo(0, h * 0.8);
    path.quadraticBezierTo(w / 2, h * 1.1, w, h * 0.8);
    path.lineTo(w, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
