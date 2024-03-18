import 'package:flutter/material.dart';
import 'package:troco/app/asset-manager.dart';

class Logo extends StatelessWidget {
  final double size;
  final BoxShape shape;
  const Logo({super.key, this.size = 120, this.shape = BoxShape.circle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        image: DecorationImage(image: AssetImage(AssetManager.imageFile(name: "app-icon")),
        fit: BoxFit.cover
        )
      ),
    );
  }
}