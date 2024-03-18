import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  /// The [lottieRes] is the FULL asset path of the lottie file.
  final String lottieRes;

  /// The [size] of the lottie
  final Size size;

  /// The [fit] is the fit of the lottie, usually defaults to BoxFit.scaleDown
  final BoxFit? fit;

  /// The [color] is the color or tint of the lottie
  final Color? color;
  const LottieWidget({super.key, required this.lottieRes,required this.size, this.color, this.fit});

  @override
  Widget build(BuildContext context) {
    return color != null? ColorFiltered(colorFilter: ColorFilter.mode(color!, BlendMode.srcIn), child: lottie()): lottie();
  }

  Widget lottie(){
    return Lottie.asset(
      lottieRes, 
      width: size.width, 
      height: size.height,
      fit: fit ?? BoxFit.cover,
      animate: true,
      repeat: true
    );
  }
}