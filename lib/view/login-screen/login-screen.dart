import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/value-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';

import '../../app/routes-manager.dart';
import '../../app/size-manager.dart';
import '../../custom-views/info-text.dart';
import '../../custom-views/text-form-field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SizeManager.medium,
                      vertical: SizeManager.regular,
                    ),
                    child: Text(
                      "Keep Connected",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          color: ColorManager.primary,
                          fontSize: FontSizeManager.extralarge,
                          fontWeight: FontWeightManager.extrabold),
                    ),
                  ),
                  mediumSpacer(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SizeManager.medium,
                      vertical: SizeManager.regular,
                    ),
                    child: Text(
                      ValuesManager.dummyDescription,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          height: 1.36,
                          wordSpacing: 1.2,
                          color: ColorManager.secondary,
                          fontSize: FontSizeManager.medium,
                          fontWeight: FontWeightManager.semibold),
                    ),
                  ),
                  mediumSpacer(),
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
                      text: "Forgot Password?",
                      color: ColorManager.themeColor,
                      alignment: Alignment.centerRight,
                      fontWeight: FontWeightManager.extrabold,
                    ),
                  ),
                  regularSpacer(),
                  CustomButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.otpLoginRoute),
                    label: "LOGIN",
                    margin: const EdgeInsets.symmetric(
                        horizontal: SizeManager.large,
                        vertical: SizeManager.medium),
                  ),
                  extraLargeSpacer(),
                  dontHaveAccount()
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
                  "Login to account",
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

  Widget dontHaveAccount() {
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
          const TextSpan(text: "Don't Have Account? "),
          TextSpan(
              text: "Register",
              style: highlightStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pushReplacementNamed(
                    context, Routes.registerRoute))
        ]));
  }
}
