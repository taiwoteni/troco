import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/lottie.dart';
import 'package:troco/data/login-data.dart';
import 'package:troco/providers/client-provider.dart';
import '../../app/color-manager.dart';

class RegisterSuccessScreen extends ConsumerStatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  ConsumerState<RegisterSuccessScreen> createState() =>
      _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends ConsumerState<RegisterSuccessScreen> {
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
          size: const Size.square(IconSizeManager.extralarge * 5.5),
          fit: BoxFit.cover,
          loop: false,
        ),
        Text(
          "Registeration Complete.",
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Lato',
              fontWeight: FontWeightManager.semibold,
              fontSize: FontSizeManager.large * 0.9),
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
        onPressed: () {
          ClientProvider.saveUserData(ref: ref, json: LoginData.toClientJson());
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.homeRoute, (route) => false);
        },
        label: "LET'S GO",
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManager.regular, vertical: SizeManager.medium),
      ),
    );
  }
}
