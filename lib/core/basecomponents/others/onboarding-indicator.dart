// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class OnboardingIndicator extends StatelessWidget {
  bool checked;
  OnboardingIndicator({super.key, required this.checked});

  @override
  Widget build(BuildContext context) {
    double normalSize = IconSizeManager.small * 0.6;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: checked ? 4 : 2, vertical: 6),
      height: normalSize,
      width: checked ? normalSize * 3 : normalSize,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          color: checked
              ? ColorManager.themeColor
              : ColorManager.themeColor.withOpacity(0.4)),
    );
  }
}
