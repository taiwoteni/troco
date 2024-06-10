import 'package:flutter/widgets.dart';

class EscrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    final w = size.width;
    final h = size.height;

    final startPoint = Offset(0, h * .75);
    final control1 = Offset(w * .02, h);
    final end1 = Offset(w * .6, h * .75);
    final control2 = Offset(w * .9, h * .6);
    final end2 = Offset(w, h * .75);

    path.lineTo(startPoint.dx, startPoint.dy);
    path.quadraticBezierTo(control1.dx, control1.dy, end1.dx, end1.dy);
    path.quadraticBezierTo(control2.dx, control2.dy, end2.dx, end2.dy);
    path.lineTo(w, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
