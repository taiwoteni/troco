// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../utils/phone-number-converter.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<ForgotPasswordScreen> {
  final UniqueKey buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool isNumber = false;
  bool primaryPasswordError = false;
  List<String> emails = [];
  List<String> phoneNumbers = ["+2349068345482"];

  @override
  void initState() {
    getEmails();
    super.initState();
  }

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
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  titleWidget(),
                  mediumSpacer(),
                  descriptionWidget(),
                  mediumSpacer(),
                  emailOrPhoneInput(),
                  passwordInput(),
                  regularSpacer(),
                  passwordDetails(),
                  regularSpacer(),
                  confirmPasswordInput(),
                  largeSpacer(),
                  CustomButton(
                    buttonKey: buttonKey,
                    onPressed: next,
                    label: "NEXT",
                    usesProvider: true,
                    margin: const EdgeInsets.symmetric(
                        horizontal: SizeManager.large,
                        vertical: SizeManager.medium),
                  ),
                  extraLargeSpacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validate(String? value) {
    if (value == null) {
      return "* enter your email or phone number.";
    }
    if (value.trim().isEmpty) {
      return "* enter your email or phone number.";
    }
    bool isPhone = isPhoneNumberOrPlus(value);
    bool validated =
        isPhone ? validatePhoneNumber(value) : EmailValidator.validate(value);
    bool exists = !isPhone
        ? emails.contains(value.trim())
        : phoneNumbers
            .contains(PhoneNumberConverter.convertToFull(value.trim()));

    return validated && exists
        ? null
        : isPhone
            ? !validated
                ? "* enter a valid phone number."
                : "* not a registered number"
            : !validated
                ? "* enter a valid email"
                : "* not a registered email";
  }

  bool isPhoneNumberOrPlus(String input) {
    final RegExp phoneRegExp = RegExp(r'^\+?\d+$');
    return phoneRegExp.hasMatch(input);
  }

  bool validatePhoneNumber(String phoneNumber) {
    final String number = phoneNumber.trim();
    // Define the regex pattern for a phone number
    RegExp regExp = RegExp(r'^\d{11,14}$');
    // Check if the input matches the regex pattern
    bool is11 = number.length == 11 && !number.contains("+");
    bool is14 = number.length == 14 && number.startsWith("+234");
    bool is13 = number.length == 13 && number.startsWith("234");
    bool is12 = number.length == 12;
    return (regExp.hasMatch(number) || is11 || is14) && !is13 && !is12;
  }

  bool validatePassword(String input) {
    RegExp regExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regExp.hasMatch(input);
  }

  Future<void> getEmails() async {
    //... Logic to get all emails
    //... And throw error when emails could not be fetched.
  }

  Future<void> next() async {
    LoginData.clear();
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await Future.delayed(const Duration(seconds: 2));
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      final verified = Navigator.pushNamed(context, Routes.otpRoute);
    }
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
  }

  // Widgets.

  Widget titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Text(
        "Forgot Password",
        textAlign: TextAlign.start,
        style: TextStyle(
            fontFamily: 'Lato',
            color: ColorManager.primary,
            fontSize: FontSizeManager.extralarge,
            fontWeight: FontWeightManager.extrabold),
      ),
    );
  }

  Widget descriptionWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Text(
        "Forgot Password? No Fear!\nEnter your account email or phone number and type in the new password.",
        textAlign: TextAlign.left,
        style: TextStyle(
            fontFamily: 'Lato',
            height: 1.36,
            wordSpacing: 1.2,
            color: ColorManager.secondary,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget emailOrPhoneInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.emailAddress,
        label: "email or phone number",
        validator: validate,
        onChanged: (value) {
          setState(() {
            isNumber = isPhoneNumberOrPlus(value.trim());
          });
        },
        onSaved: (emailOrNumber) {
          if (emailOrNumber == null) {
            return;
          }
          // if it is a phone number
          if (isPhoneNumberOrPlus(emailOrNumber.trim())) {
            /// Since onSaved means that there was no
            /// error when validating then it can only be either
            /// 11 digits or 14 digits.
            LoginData.phoneNumber =
                PhoneNumberConverter.convertToFull(emailOrNumber);
          } else {
            LoginData.email = emailOrNumber.trim();
          }
        },
        prefixIcon: isNumber ? phoneIcon() : emailIcon(),
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.visiblePassword,
        isPassword: true,
        label: "new password",
        validator: (value) {
          if (value == null) {
            setState(() {
              primaryPasswordError = true;
            });
            return "";
          }
          LoginData.password = value.trim();

          setState(() => primaryPasswordError = !validatePassword(value));
          return null;
        },
        onSaved: (value) {
          LoginData.password = value;
        },
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
    );
  }

  Widget passwordDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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

  Widget confirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.visiblePassword,
        isPassword: true,
        label: "confirm new password",
        validator: (value) {
          if (value == null) {
            return "* enter a valid password.";
          }
          return LoginData.password == value.trim() && value.isNotEmpty
              ? null
              : "* passwords don't match";
        },
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
    );
  }

  Widget phoneIcon() {
    return IconButton(
      onPressed: null,
      iconSize: IconSizeManager.regular,
      icon: Icon(
        CupertinoIcons.phone_solid,
        color: ColorManager.themeColor,
      ),
    );
  }

  Widget emailIcon() {
    return IconButton(
      onPressed: null,
      iconSize: IconSizeManager.regular,
      icon: SvgIcon(
        svgRes: AssetManager.svgFile(name: "email"),
        color: ColorManager.themeColor,
        fit: BoxFit.cover,
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
                  "Reset Password",
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
}
