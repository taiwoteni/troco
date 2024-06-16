import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';

import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';

class KycVerificationIntroScreen extends ConsumerStatefulWidget {
  const KycVerificationIntroScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState
    extends ConsumerState<KycVerificationIntroScreen> {
  final buttonKey = UniqueKey();
  bool verified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            lottie(),
            title(),
            largeSpacer(),
            label(),
            mediumSpacer(),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer(),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return const Text(
      "KYC Verification",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.black,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large,
          fontWeight: FontWeightManager.bold),
    );
  }

  Widget label() {
    return Text(
      "Verify your proof of identity.\nFor security and authenticity in your transactions.\nThank you for your cooperation.",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 1.1,
          fontWeight: FontWeightManager.regular),
    );
  }

  Widget lottie() {
    return Transform.scale(
      scale: 1.2,
      child: LottieWidget(
        lottieRes: AssetManager.lottieFile(name: 'kyc'),
        fit: BoxFit.cover,
        size: const Size.square(IconSizeManager.extralarge * 4),
      ),
    );
  }

  Widget button() {
    return CustomButton(
      usesProvider: true,
      buttonKey: buttonKey,
      onPressed: go,
      label: "GO",
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }

  Future<void> go() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final verified =
        (await Navigator.pushNamed(context, Routes.kycVerificationRoute))
                as bool? ??
            false;
    if (verified) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => this.verified = verified);
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
