import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';

class NoPaymentMethod extends StatelessWidget {
  const NoPaymentMethod({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieWidget(
            lottieRes: AssetManager.lottieFile(name: "card"), 
            fit: BoxFit.cover,
            loop: false,
            size: const Size.square(IconSizeManager.extralarge * 2)),
          largeSpacer(),
          Text(
            "Add a payment Method.\nMake Life smooth.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'lato',
              fontSize: FontSizeManager.regular,
              color: ColorManager.secondary,
              fontWeight: FontWeightManager.regular,
            ),
          )

        ],
      ),
    );
  }
}