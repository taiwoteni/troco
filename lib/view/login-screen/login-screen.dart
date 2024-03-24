import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/data/converters.dart';
import 'package:troco/data/login-data.dart';
import 'package:troco/providers/button-provider.dart';

import '../../app/routes-manager.dart';
import '../../app/size-manager.dart';
import '../../custom-views/info-text.dart';
import '../../custom-views/text-form-field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final UniqueKey buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool isNumber = false;
  List<String> emails = ["taiwoteninlanimi@gmail.com"];
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
                      "Log in with your email or phone number.\nKeep the details of your account private.",
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      label: "password",
                      validator: (value) {
                        if (value == null) {
                          return "* enter your password.";
                        }
                        return value.isNotEmpty
                            ? null
                            : "* enter a valid password.";
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
                  ),
                  regularSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: SizeManager.small,
                        horizontal: SizeManager.medium * 1.5),
                    child: InfoText(
                      onPressed: navigateForgetPassword,
                      text: "Forgot Password?",
                      color: ColorManager.themeColor,
                      alignment: Alignment.centerRight,
                      fontWeight: FontWeightManager.extrabold,
                    ),
                  ),
                  regularSpacer(),
                  CustomButton(
                    buttonKey: buttonKey,
                    onPressed: next,
                    label: "LOGIN",
                    usesProvider: true,
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

  void navigateForgetPassword() {
    Navigator.pushNamed(context, Routes.forgotPasswordRoute);
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

  Future<void> getEmails() async {
    //... Logic to get all emails
    //... And throw error when emails could not be fetched.
  }

  Future<void> next() async {
    ///... Here an awaited future that would get all clients
    ///... and should be run. and should be saved to the List<Client>.
    ///... Then during the [validator] in the forms. They should based on their constraints.
    ///... @finbar should create an api request on his end for this. One that only passes email and password.
    ///... inorder to reduce processing time and size.

    /// A problem arose whereby @taiwoteni couldn't tell
    /// how to correctly clear all login details when change number/email or dispose
    /// was called in the OTPScreen. So to be on the safe side, We clear before validation.
    LoginData.clear();

    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await Future.delayed(const Duration(seconds: 2));
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      Navigator.pushNamed(context, Routes.otpLoginRoute);
    }
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
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
