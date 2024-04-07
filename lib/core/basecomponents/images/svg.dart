import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  /// The [svgRes] is the FULL asset path of the svg file.
  final String svgRes;

  /// The [size] of the svg
  final Size? size;

  /// The [fit] is the fit of the svg, usually defaults to BoxFit.scaleDown
  final BoxFit? fit;

  /// The [angle] is the degree rotation of the svg, usually defaults to 0

  final double angle;

  /// The [color] is the color or tint of the svg
  final Color? color;
  const SvgIcon(
      {super.key,
      required this.svgRes,
      this.angle = 0,
      this.size,
      this.color,
      this.fit});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SvgPicture.asset(
        svgRes,
        color: color,
        width: size == null ? null : size!.width,
        height: size == null ? null : size!.height,
        fit: fit ?? BoxFit.contain,
      ),
    );
  }
}
