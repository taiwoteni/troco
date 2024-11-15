// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/data/models/otp-data.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/texts/inputs/otp-input-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../auth/utils/phone-number-converter.dart';
import '../../../../settings/domain/repository/settings-repository.dart';

class ForgotPinScreen extends ConsumerStatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  ConsumerState<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends ConsumerState<ForgotPinScreen> {
  final UniqueKey buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  String oldPin1 = "", oldPin2 = "", oldPin3 = "", oldPin4 = "";
  String newPin1 = "", newPin2 = "", newPin3 = "", newPin4 = "";
  bool isNumber = false;

  @override
  void initState() {
    super.initState();
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorManager.background,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleWidget(),
                mediumSpacer(),
                descriptionWidget(),
                mediumSpacer(),
                emailOrPhoneInput(),
                regularSpacer(),
                newPin(),
                regularSpacer(),
                confirmPin(),
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
    // bool exists = !isPhone
    //     ? emails.contains(value.trim())
    //     : phoneNumbers
    //         .contains(PhoneNumberConverter.convertToFull(value.trim()));

    return validated
        ? null
        : isPhone
            ? "* enter a valid phone number."
            : "* enter a valid email";
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

  Future<void> next() async {
    LoginData.clear();
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    if (formKey.currentState!.validate()) {
      if ("$oldPin1$oldPin2$oldPin3$oldPin4" !=
          "$newPin1$newPin2$newPin3$newPin4") {
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Pins don't match");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        return;
      }
      formKey.currentState!.save();
      await requestPinReset();
    }
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
  }

  Future<void> changePin() async {
    final response = await SettingsRepository.resetPin(
        email: LoginData.email,
        phoneNumber: LoginData.phoneNumber,
        newPin: "$newPin1$newPin2$newPin3$newPin4");
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    debugPrint(response.body);
    if (!response.error) {
      SnackbarManager.showBasicSnackbar(
          context: context, message: "Successfully reset pin");
      Navigator.pop(context);
    } else {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Couldn't reset pin.");
    }
  }

  Future<void> verifyOtp() async {
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    final verified = (await Navigator.pushNamed(context, Routes.otpRoute,
            arguments: OtpVerificationType.ForgotPin)) as bool? ??
        false;
    if (verified) {
      ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
      await changePin();
    } else {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Couldn't verify ${isNumber ? "phone number" : "email"}");
    }
  }

  Future<void> requestPinReset() async {
    final response = await SettingsRepository.requestPinReset(
        email: LoginData.email, phoneNumber: LoginData.phoneNumber);
    debugPrint(response.body);
    OtpData.clear();
    OtpData.id = response.messageBody!["data"]["_id"];
    OtpData.email = LoginData.email;
    OtpData.phoneNumber = response.messageBody!["data"]["phoneNumber"];
    LoginData.otp = response.messageBody?["data"]["verificationPin"];

    if (!response.error) {
      await verifyOtp();
    } else {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Internet error occured");
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
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
        "Forgot Pin",
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
        "Enter your account email or\nphone number and type in the new pin.",
        textAlign: TextAlign.left,
        style: TextStyle(
            fontFamily: 'Lato',
            height: 1.36,
            wordSpacing: 1.2,
            color: ColorManager.secondary,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.regular),
      ),
    );
  }

  Widget emailOrPhoneInput() {
    return Form(
      key: formKey,
      child: Padding(
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

  Widget confirmPin() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Confirm New Pin",
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
        mainAxisAlignment: MainAxisAlignment.end,
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
