import 'package:flutter/material.dart';
import 'package:troco/features/onboarding/data/models/onboarding-item-model.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';

class OnboardingItemWidget extends StatelessWidget {
  final OnboardingItemModel onboardingItem;
  const OnboardingItemWidget({super.key, required this.onboardingItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RATIO: 5:2
        extraLargeSpacer(),
        extraLargeSpacer(),
        Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                onboardingItem.imgRes,
                width: IconSizeManager.extralarge * 4.5,
                height: IconSizeManager.extralarge * 4.5,
                fit: BoxFit.cover,
              ),
            )),
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  onboardingItem.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorManager.themeColor,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.extralarge * 0.95),
                ),
                regularSpacer(),
                Text(
                  onboardingItem.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: FontSizeManager.medium * 0.96,
                      color: ColorManager.secondary,
                      fontWeight: FontWeightManager.medium),
                )
              ],
            ))
      ],
    );
  }
}
