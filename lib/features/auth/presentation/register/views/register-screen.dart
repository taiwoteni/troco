import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/texts/inputs/text-form-field.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/data/models/otp-data.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../utils/phone-number-converter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();

  // used to indicate wether the error message was based on the email or phone number
  String? phoneError, emailError;
  bool primaryPasswordError = false;
  List<String> emails = [];
  List<String> phoneNumbers = [];

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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      inputType: TextInputType.emailAddress,
                      label: "email",
                      validator: (value) {
                        if (value == null) {
                          return "* enter your email";
                        }
                        if (emails.contains(value.trim())) {
                          return "* email already exists.";
                        }
                        if (emailError != null) {
                          return emailError;
                        }
                        return EmailValidator.validate(value) &&
                                value.isNotEmpty
                            ? null
                            : "* enter a valid email.";
                      },
                      onSaved: (value) {
                        LoginData.email = value?.trim();
                      },
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
                      validator: (value) {
                        if (value == null) {
                          return "* enter your phone number.";
                        }
                        if (phoneNumbers.contains(value.trim())) {
                          return "* phone number already exists.";
                        }
                        if (value.startsWith("+234") && value.length != 14) {
                          return "* enter valid phone number";
                        }
                        if (value.length != 11) {
                          return "* enter valid phone number";
                        }
                        if (phoneError != null) {
                          return phoneError;
                        }
                        return validatePhoneNumber(value.trim())
                            ? null
                            : "* enter valid phone number.";
                      },
                      onSaved: (value) {
                        if (value == null) {
                          return;
                        }
                        LoginData.phoneNumber =
                            PhoneNumberConverter.convertToFull(value);
                      },
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
                      validator: (value) {
                        if (value == null) {
                          setState(() {
                            primaryPasswordError = true;
                          });
                          return "";
                        }
                        LoginData.password = value.trim();

                        setState(() =>
                            primaryPasswordError = !validatePassword(value));

                        return null;
                      },
                      onSaved: (value) {
                        LoginData.password = value?.trim();
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
                      text: "* should be at least 8 digits in length.",
                      color: primaryPasswordError
                          ? Colors.red
                          : ColorManager.secondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                            vertical: SizeManager.small,
                            horizontal: SizeManager.medium) *
                        1.5,
                    child: InfoText(
                      text: "* should have at least a number and a letter.",
                      color: primaryPasswordError
                          ? Colors.red
                          : ColorManager.secondary,
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
                      validator: (value) {
                        if (value == null) {
                          return "* enter a valid password.";
                        }
                        return LoginData.password == value.trim() &&
                                value.isNotEmpty
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
                  ),
                  largeSpacer(),
                  CustomButton(
                    onPressed: next,
                    buttonKey: buttonKey,
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

  Future<void> register() async {
    log(LoginData.phoneNumber!.toString());
    log(LoginData.email!.toString());
    log(LoginData.password!.toString());

    // if user has already created account and verified;
    if (LoginData.id != null && !OtpData.isVerifying()) {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      Navigator.pushNamed(context, Routes.setupAccountRoute);
      return;
    }

    // if user had created this account but is still verfying
    if (OtpData.isVerifying()) {
      verify(result: OtpData.model!);
    } else {
      final result = await AuthenticationRepo.registerUser(
          email: LoginData.email!,
          phoneNumber: LoginData.phoneNumber!,
          password: LoginData.password!);
      log(result.body);

      if (!result.error) {
        OtpData.id = result.messageBody!["data"]["_id"];
        OtpData.email = LoginData.email;
        OtpData.phoneNumber = LoginData.phoneNumber;
        OtpData.password = LoginData.password;
        OtpData.model = result;
        LoginData.otp = result.messageBody!["data"]["verificationPin"];
        log(OtpData.id!);
        verify(result: result);
      } else {
        log(result.code.toString());
        print(result.body);
        if (result.messageBody!["error"].toString().contains("duplicate")) {
          setState(() {
            if (result.messageBody!["error"]
                .toString()
                .contains("phoneNumber")) {
              phoneError = "* phone number already exists";
            } else {
              phoneError = null;
            }
            if (result.messageBody!["error"].toString().contains("email")) {
              emailError = "* email already exists";
            } else {
              emailError = null;
            }
          });
          formKey.currentState!.validate();

          /// we only use those bools in the validator for error showing purposes
          /// if left after validate() is called, registration will not hold
          /// cos the validate() function in the if statement will be false
          setState(() {
            phoneError = null;
            emailError = null;
          });
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
    }
  }

  Future<void> next() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    if (formKey.currentState!.validate() && !primaryPasswordError) {
      formKey.currentState!.save();
      await Future.delayed(const Duration(seconds: 2));
      register();
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }

  Future<void> verify({required final HttpResponseModel result}) async {
    final verified =
        (await Navigator.pushNamed(context, Routes.otpRoute) as bool? ?? false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    if (verified) {
      LoginData.id = result.messageBody!["data"]["_id"];
      LoginData.otp = result.messageBody!["data"]["verificationPin"].toString();
      OtpData.clear();
      Navigator.pushReplacementNamed(context, Routes.setupAccountRoute);
    }
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
            const TextSpan(text: "By registering, you agree to Escrow's "),
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
}
