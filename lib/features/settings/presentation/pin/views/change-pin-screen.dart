import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:troco/core/components/button/presentation/widget/button.dart";
import "package:troco/core/components/texts/inputs/otp-input-field.dart";

import "../../../../../core/app/asset-manager.dart";
import "../../../../../core/app/color-manager.dart";
import "../../../../../core/app/font-manager.dart";
import "../../../../../core/app/size-manager.dart";
import "../../../../../core/components/button/presentation/provider/button-provider.dart";
import "../../../../../core/components/images/svg.dart";
import "../../../../../core/components/others/spacer.dart";
import "../../../../../core/components/texts/outputs/info-text.dart";

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  String oldPin1 = "", oldPin2 = "", oldPin3 = "", oldPin4 = "";
  String newPin1 = "", newPin2 = "", newPin3 = "", newPin4 = "";

  final UniqueKey buttonKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
    if (oldPin1.isNotEmpty &&
        oldPin2.isNotEmpty &&
        oldPin3.isNotEmpty &&
        oldPin4.isNotEmpty &&
        newPin1.isNotEmpty &&
        newPin2.isNotEmpty &&
        newPin3.isNotEmpty &&
        newPin4.isNotEmpty) {
      ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
    } else {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            largeSpacer(),
            oldPin(),
            mediumSpacer(),
            forgotPin(),
            mediumSpacer(),
            newPin(),
            extraLargeSpacer(),
            button()
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(72 + MediaQuery.of(context).viewPadding.top),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Change Pin",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget oldPin() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Old Pin",
              color: ColorManager.accentColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          Form(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OtpInputField(
                first: true,
                obscure: true,
                onEntered: (value) {
                  setState(() => oldPin1 = value);
                },
              ),
              OtpInputField(
                obscure: true,
                onEntered: (value) {
                  setState(() => oldPin2 = value);
                },
              ),
              OtpInputField(
                obscure: true,
                onEntered: (value) {
                  setState(() => oldPin3 = value);
                },
              ),
              OtpInputField(
                last: true,
                obscure: true,
                onEntered: (value) {
                  setState(() => oldPin4 = value);
                },
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget newPin() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "New Pin",
              color: ColorManager.accentColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          Form(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OtpInputField(
                first: true,
                obscure: true,
                onEntered: (value) {
                  setState(() => newPin1 = value);
                },
              ),
              OtpInputField(
                obscure: true,
                onEntered: (value) {
                  setState(() => newPin2 = value);
                },
              ),
              OtpInputField(
                obscure: true,
                onEntered: (value) {
                  setState(() => newPin3 = value);
                },
              ),
              OtpInputField(
                last: true,
                obscure: true,
                onEntered: (value) {
                  setState(() => newPin4 = value);
                },
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget forgotPin() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: InfoText(
        text: "Forgot Pin?",
        alignment: Alignment.centerRight,
        fontWeight: FontWeightManager.semibold,
      ),
    );
  }

  Widget button() {
    return CustomButton(
      label: "Change Pin",
      usesProvider: true,
      buttonKey: buttonKey,
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }
}
