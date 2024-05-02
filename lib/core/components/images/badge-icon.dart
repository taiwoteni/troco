import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';

enum BadgeIconType { svg, asset, icon }

class BadgeIcon extends StatelessWidget {
  BadgeIcon(
      {super.key,
      required this.iconType,
      this.size,
      this.fillColor,
      this.stroke,
      this.strokeColor,
      this.iconData,
      this.iconString}) {
    if (iconType == BadgeIconType.icon && iconData == null) {
      throw Exception("BadeIconType is icon but the iconInt is null!!");
    } else if (iconType == BadgeIconType.asset ||
        iconType == BadgeIconType.svg && iconString == null) {
      throw Exception(
          "BadgeIconType is svg or asset but the iconString is null!!");
    }
  }

  final double? size;
  final BadgeIconType iconType;
  final String? iconString;
  final IconData? iconData;
  final Color? fillColor;
  final double? stroke;
  final Color? strokeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? IconSizeManager.regular * 1.7,
      height: size ?? IconSizeManager.regular * 1.7,
      padding: EdgeInsets.all(stroke ?? SizeManager.small),
      decoration: BoxDecoration(
          color: strokeColor ?? ColorManager.background,
          shape: BoxShape.circle),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: fillColor ?? ColorManager.accentColor,
            shape: BoxShape.circle),
        child: icon(),
      ),
    );
  }

  Widget icon() {
    final double size = this.size ?? IconSizeManager.regular * 1.7;
    switch (iconType) {
      case BadgeIconType.asset:
        return Image.asset(
          iconString!,
          width: size * 0.5,
          height: size * 0.5,
          fit: BoxFit.cover,
        );
      case BadgeIconType.svg:
        return SvgIcon(
          svgRes: iconString!,
          color: Colors.white,
          size: Size.square(size * 0.5),
        );
      default:
        return Icon(
          iconData,
          size: size * 0.5,
          color: Colors.white,
        );
    }
  }
}
