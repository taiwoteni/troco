import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  /// The [svgRes] is the FULL asset path of the lottie file.
  final String svgRes;

  /// The [size] of the lottie
  final Size? size;

  /// The [fit] is the fit of the lottie, usually defaults to BoxFit.scaleDown
  final BoxFit? fit;

  /// The [color] is the color or tint of the lottie
  final Color? color;
  const SvgIcon(
      {super.key, required this.svgRes, this.size, this.color, this.fit});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgRes,
      color: color,
      width: size == null? null:size!.width,
      height: size == null? null:size!.height,
      fit: fit ?? BoxFit.contain,
    );
  }
}
