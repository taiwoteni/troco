import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final Color infoColor = ColorManager.accentColor;
  bool primaryPasswordError = false;
  final GlobalKey formKey = GlobalKey<FormState>();
  final UniqueKey buttonKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: ColorManager.background,
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                largeSpacer(),
                oldPassword(),
                mediumSpacer(),
                forgotPassword(),
                mediumSpacer(),
                newPassword(),
                mediumSpacer(),
                newPasswordGuidelines(),
                mediumSpacer(),
                confirmPassword(),
                extraLargeSpacer(),
                button(),
                largeSpacer(),
              ],
            ),
          ),
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
                  "Change Password",
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

  Widget oldPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Old Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in your old password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* enter password";
              }
              if (value.trim().isEmpty) {
                return "* enter password";
              }
              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: InfoText(
        onPressed: () =>
            Navigator.pushNamed(context, Routes.forgotPasswordRoute),
        text: "Forgot Password?",
        alignment: Alignment.centerRight,
        fontWeight: FontWeightManager.semibold,
      ),
    );
  }

  Widget newPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "New Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in the new password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* enter password";
              }
              if (value.trim().isEmpty) {
                return "* enter password";
              }
              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget newPasswordGuidelines() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small,
              horizontal: SizeManager.medium * 1.5),
          child: InfoText(
            text: "* should be at least 8 digits in length.",
            color: primaryPasswordError ? Colors.red : ColorManager.secondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
                  vertical: SizeManager.small, horizontal: SizeManager.medium) *
              1.5,
          child: InfoText(
            text: "* should have at least a number and a letter.",
            color: primaryPasswordError ? Colors.red : ColorManager.secondary,
          ),
        ),
      ],
    );
  }

  Widget confirmPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Confirm Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Retype the new password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* enter password";
              }
              if (value.trim().isEmpty) {
                return "* enter password";
              }
              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  bool validatePassword(String input) {
    RegExp regExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regExp.hasMatch(input);
  }

  Widget button() {
    return CustomButton(
      label: "Change",
      buttonKey: buttonKey,
      usesProvider: true,
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }
}
