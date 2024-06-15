import 'package:flutter/material.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class PinKeypadWidget extends StatelessWidget {
  const PinKeypadWidget({
    super.key,
    required this.text,
    this.onTap,
  });

  final void Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.8),
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(SizeManager.large * 1.5),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.2),
            ], begin: Alignment.topCenter, end: Alignment.bottomRight)),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: FontSizeManager.large,
              fontWeight: FontWeightManager.extrabold,
              fontFamily: 'lato'),
        ),
      ),
    );
  }
}
