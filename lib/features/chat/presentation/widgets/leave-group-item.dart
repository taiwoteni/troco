import 'package:flutter/material.dart';
import 'package:troco/core/components/images/profile-icon.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';

class LeaveGroupItem extends StatelessWidget {
  final bool selected;
  final void Function() onChecked;
  final String label, description, profile;
  const LeaveGroupItem(
      {super.key,
      required this.selected,
      required this.onChecked,
      required this.label,
      required this.profile,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {
        onChecked();
      },
      child: Container(
        width: double.maxFinite,
        height: 85,
        decoration: BoxDecoration(
            color: selected
                ? ColorManager.accentColor.withOpacity(0.05)
                : ColorManager.background,
            border: Border.all(
                color: selected
                    ? ColorManager.accentColor
                    : ColorManager.secondary.withOpacity(0.09),
                width: 2),
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: Row(
          children: [
            regularSpacer(),
            ProfileIcon(
              url: profile,
              size: 50,
            ),
            mediumSpacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.medium * 0.9,
                      fontWeight: FontWeightManager.semibold),
                ),
                smallSpacer(),
                Text(
                  description,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.regular * 0.72,
                      fontWeight: FontWeightManager.semibold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
