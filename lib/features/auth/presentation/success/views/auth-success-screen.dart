import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/value-manager.dart';

class AuthSuccessScreen extends ConsumerStatefulWidget {
  const AuthSuccessScreen({super.key});

  @override
  ConsumerState<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends ConsumerState<AuthSuccessScreen> {
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
            detailsScreen(),
            nextButton(),
          ],
        ),
      ),
    );
  }

  Widget detailsScreen() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: LottieWidget(
            lottieRes: AssetManager.lottieFile(name: 'success'),
            loop: false,
            size: const Size(
              double.maxFinite,
              IconSizeManager.extralarge * 6,
            ),
          ),
        ),
        mediumSpacer(),
        Text(
          "Congratulations",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Lato",
            fontSize: FontSizeManager.large,
            fontWeight: FontWeightManager.extrabold,
            color: ColorManager.primary,
          ),
        ),
        largeSpacer(),
        Text(
          ValuesManager.authSuccessString,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeightManager.medium,
            color: ColorManager.secondary,
            fontSize: FontSizeManager.medium * 0.9,
            height: 1.36,
            wordSpacing: 1.2,
            fontFamily: 'Lato',
          ),
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
