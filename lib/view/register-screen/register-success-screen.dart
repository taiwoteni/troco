import 'package:flutter/material.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/lottie.dart';
import 'package:troco/custom-views/spacer.dart';
import '../../app/color-manager.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.background,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            registerSuccess(),
            nextButton(),
          ],
        ),
      ),
    );
  }

  Widget registerSuccess() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieWidget(
          lottieRes: AssetManager.lottieFile(name: 'success'),
          size: const Size.square(IconSizeManager.extralarge * 1.2),
          fit: BoxFit.cover,
        ),
        mediumSpacer(),
        Text(
          "Registeration Complete",
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontWeight: FontWeightManager.semibold,
              fontSize: FontSizeManager.large),
        ),
      ],
    ));
  }

  Widget nextButton() {
    return Padding(
      padding: const EdgeInsets.only(
          left: SizeManager.regular,
          right: SizeManager.regular,
          bottom: SizeManager.extralarge),
      child: CustomButton(
        label: "LET'S GO",
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManager.regular, vertical: SizeManager.medium),
      ),
    );
  }
}
