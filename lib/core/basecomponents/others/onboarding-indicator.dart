// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class OnboardingIndicator extends StatelessWidget {
  bool checked;
  Color? checkedColor;
  OnboardingIndicator({super.key, this.checkedColor, required this.checked});

  @override
  Widget build(BuildContext context) {
    double normalSize = IconSizeManager.small * 0.6;
    final color = checkedColor ?? ColorManager.themeColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: checked ? 4 : 2, vertical: 6),
      height: normalSize,
      width: checked ? normalSize * 3 : normalSize,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          color: checked
              ? color
              : color.withOpacity(0.4)),
    );
  }
}
