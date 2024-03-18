import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/info-text.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/custom-views/text-form-field.dart';

import '../../app/routes-manager.dart';
import '../../custom-views/button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorManager.background,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.emailAddress,
                      label: "email",
                      prefixIcon: IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: SvgIcon(
                          svgRes: AssetManager.svgFile(name: "email"),
                          color: ColorManager.themeColor,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.phone,
                      label: "phone",
                      prefixIcon: IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: Icon(
                          CupertinoIcons.phone_solid,
                          color: ColorManager.themeColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      label: "password",
                      prefixIcon: IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: Image.asset(
                          AssetManager.iconFile(name: "padlock"),
                          color: ColorManager.themeColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  regularSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: SizeManager.small,
                        horizontal: SizeManager.medium * 1.5),
                    child: InfoText(
                      text: "* should be at least 8 digits in length.",
                      color: ColorManager.secondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                            vertical: SizeManager.small,
                            horizontal: SizeManager.medium) *
                        1.5,
                    child: InfoText(
                      text: "* should have at least a number and a letter.",
                      color: ColorManager.secondary,
                    ),
                  ),
                  regularSpacer(),

                  // Confirm password input field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      label: "confirm password",
                      prefixIcon: IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: Image.asset(
                          AssetManager.iconFile(name: "padlock"),
                          color: ColorManager.themeColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  largeSpacer(),
                  CustomButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.otpRegisterRoute),
                        buttonKey: UniqueKey(),
                    usesProvider: true,
                    label: "REGISTER",
                    margin: const EdgeInsets.symmetric(
                        horizontal: SizeManager.large,
                        vertical: SizeManager.medium),
                  ),
                  smallSpacer(),
                  privacyPolicyText(),
                  extraLargeSpacer(),
                  alreadyHaveAccount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
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
                const Gap(16),
                Text(
                  "Register account",
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

  Widget privacyPolicyText() {
    final defaultStyle = TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular,
        fontFamily: 'Lato',
        fontWeight: FontWeightManager.medium);
    final highlightStyle = defaultStyle.copyWith(
      color: ColorManager.themeColor,
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: defaultStyle, children: [
            const TextSpan(text: "By registering, you agree to Estaco's "),
            TextSpan(
                text: "Terms of using the Troco Platform",
                style: highlightStyle,
                recognizer: TapGestureRecognizer()..onTap = () {}),
            const TextSpan(text: " and its "),
            TextSpan(text: "Privacy Policy", style: highlightStyle),
            const TextSpan(text: ".")
          ])),
    );
  }

  Widget alreadyHaveAccount() {
    final defaultStyle = TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.medium * 1.05,
        fontFamily: 'Lato',
        fontWeight: FontWeightManager.semibold);
    final highlightStyle = defaultStyle.copyWith(
      color: ColorManager.themeColor,
    );
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "Already Have Account? "),
          TextSpan(
              text: "Sign In",
              style: highlightStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.pushReplacementNamed(context, Routes.loginRoute))
        ]));
  }
}
