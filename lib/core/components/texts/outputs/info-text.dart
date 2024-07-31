import 'package:flutter/cupertino.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';

class InfoText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final void Function()? onPressed;
  final Alignment? alignment;
  const InfoText(
      {super.key,
      this.fontSize,
      required this.text,
      this.alignment,
      this.onPressed,
      this.fontWeight,
      this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Align(
        alignment: alignment ?? Alignment.centerLeft,
        child: Text(
          text,
          textAlign: (alignment ?? Alignment.centerLeft) == Alignment.center
              ? TextAlign.center
              : TextAlign.left,
          style: TextStyle(
            color: color ?? ColorManager.themeColor,
            fontFamily: 'Lato',
            fontWeight: fontWeight ?? FontWeightManager.medium,
            fontSize: fontSize ?? FontSizeManager.regular,
          ),
        ),
      ),
    );
  }
}
