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

    path_0.moveTo(size.width * -0.0040000, size.height * -0.0020000);
    path_0.lineTo(size.width, size.height * 0.0040000);
    path_0.lineTo(size.width * 1.0100000, size.height * 1.0160000);
    path_0.quadraticBezierTo(size.width * 0.9570000, size.height * 0.8690000,
        size.width * 0.8460000, size.height * 0.8860000);
    path_0.cubicTo(
        size.width * 0.8265000,
        size.height * 0.8815000,
        size.width * 0.3135000,
        size.height * 0.8850000,
        size.width * 0.1940000,
        size.height * 0.8900000);
    path_0.quadraticBezierTo(size.width * 0.0470000, size.height * 0.8740000,
        size.width * -0.0020000, size.height * 1.0100000);
    return path_0;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
