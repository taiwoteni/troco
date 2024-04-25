import 'package:flutter/material.dart';

// import '../../../../../core/app/size-manager.dart';

class TransactionProductClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    // path_0.moveTo(size.width * -0.0040000, size.height * -0.0020000);
    // path_0.lineTo(size.width, size.height * 0.0040000);
    // path_0.lineTo(size.width * 1.0020000, size.height * 0.9960000);
    // path_0.quadraticBezierTo(size.width * 0.9910000, size.height * 0.7930000,
    //     size.width * 0.8460000, size.height * 0.8000000);
    // path_0.cubicTo(
    //     size.width * 0.6705000,
    //     size.height * 0.7995000,
    //     size.width * 0.3275000,
    //     size.height * 0.7990000,
    //     size.width * 0.1520000,
    //     size.height * 0.7980000);
    // path_0.quadraticBezierTo(size.width * 0.0110000, size.height * 0.8200000,
    //     size.width * 0.0020000, size.height * 1.0020000);

    //@@@@ 2
    // path_0.moveTo(size.width * -0.0040000, size.height * -0.0020000);
    // path_0.lineTo(size.width, size.height * 0.0040000);
    // path_0.lineTo(size.width * 1.0020000, size.height * 0.9960000);
    // path_0.quadraticBezierTo(size.width * 0.9530000, size.height * 0.8830000,
    //     size.width * 0.8180000, size.height * 0.8940000);
    // path_0.cubicTo(
    //     size.width * 0.3965000,
    //     size.height * 0.8895000,
    //     size.width * 0.3975000,
    //     size.height * 0.8910000,
    //     size.width * 0.1820000,
    //     size.height * 0.8920000);
    // path_0.quadraticBezierTo(size.width * 0.0530000, size.height * 0.8900000,
    //     size.width * 0.0020000, size.height * 1.0020000);

    path_0.moveTo(0, 0);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(size.width * 1.0008000, size.height * 1.0080100);
    path_0.quadraticBezierTo(size.width * 0.9676400, size.height * 0.9035700,
        size.width * 0.8473300, size.height * 0.9006200);
    path_0.cubicTo(
        size.width * 0.8278300,
        size.height * 0.8961200,
        size.width * 0.3547300,
        size.height * 0.8936700,
        size.width * 0.1966500,
        size.height * 0.8973400);
    path_0.quadraticBezierTo(size.width * 0.0483200, size.height * 0.8879900,
        size.width * -0.0006800, size.height * 1.0066200);
    return path_0;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
