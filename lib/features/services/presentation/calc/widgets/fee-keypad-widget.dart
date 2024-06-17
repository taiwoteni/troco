import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class FeeKeypadWidget extends StatelessWidget {
  const FeeKeypadWidget({
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
      splashColor: ColorManager.accentColor.withOpacity(0.2),
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(SizeManager.large * 1.5),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorManager.accentColor.withOpacity(0.125)),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontSize: FontSizeManager.large * 0.8,
              fontWeight: FontWeightManager.extrabold,
              fontFamily: 'lato'),
        ),
      ),
    );
  }
}
