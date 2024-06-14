import 'package:flutter/material.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class PinKeypadWidget extends StatelessWidget {
  const PinKeypadWidget({
    super.key,
    required this.text,
    this.size = IconSizeManager.large,
    this.onTap,
  });

  final void Function()? onTap;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.8),
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.semibold,
            fontFamily: 'lato'),),
      ),
    );
  }
}
