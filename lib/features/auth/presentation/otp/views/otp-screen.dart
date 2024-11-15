// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/texts/inputs/otp-input-field.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/data/models/otp-data.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/otp/providers/timer-provider.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/settings/domain/repository/settings-repository.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/images/svg.dart';

enum OtpVerificationType { Authentication, ForgotPassword, ForgotPin, Update }

class OTPScreen extends ConsumerStatefulWidget {
  final OtpVerificationType otpVerificationType;
  final String target;
  final bool isEmail;
  const OTPScreen(
      {super.key,
      this.isEmail = true,
      required this.target,
      this.otpVerificationType = OtpVerificationType.Authentication});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final UniqueKey buttonKey = UniqueKey();
  late bool isEmail;
  late OtpVerificationType otpVerificationType;
  late String target;
  bool timerInitialized = false;
  bool resendCode = false;
  late TimerProvider timerProvider;

  String otpValue1 = "",
      otpValue2 = "",
      otpValue3 = "",
      otpValue4 = "",
      otpValue5 = "";

  @override
  void dispose() {
    if (timerInitialized) {
      timerProvider.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    isEmail = widget.isEmail;
    otpVerificationType = widget.otpVerificationType!;
    target = widget.target;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
      timerProvider = TimerProvider(
        duration: const Duration(seconds: 60),
        ref: ref,
        onComplete: () {
          setState(() {
            resendCode = true;
          });
        },
      );

      setState(() => timerInitialized = true);

      timerProvider.start();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
    if (otpValue1.isNotEmpty &&
        otpValue2.isNotEmpty &&
        otpValue3.isNotEmpty &&
        otpValue4.isNotEmpty &&
        otpValue5.isNotEmpty) {
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
                    "Verification Code",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Lato',
                        color: ColorManager.primary,
                        fontSize: FontSizeManager.extralarge,
                        fontWeight: FontWeightManager.extrabold),
                  ),
                ),
                mediumSpacer(),
                descriptionWidget(),
                mediumSpacer(),
                otpRow(),
                regularSpacer(),
                resendCodeWidget(),
                regularSpacer(),
                buttonWidget()
              ],
            )),
          ),
        ),
      ),
    );
  }

  //661011867896deefa607ac81

  Future<HttpResponseModel> verifyOtpRequest() async {
    switch (otpVerificationType) {
      case OtpVerificationType.Update:
        return await AuthenticationRepo.verifyUpdateProfileOTP(
          userId: OtpData.id ?? ClientProvider.readOnlyClient!.userId,
          otp: otpValue1 + otpValue2 + otpValue3 + otpValue4 + otpValue5,
        );

      case OtpVerificationType.ForgotPassword:
        return await SettingsRepository.verifyPasswordResetOtp(
          emailOrPhone: target,
          otp: otpValue1 + otpValue2 + otpValue3 + otpValue4 + otpValue5,
        );

      case OtpVerificationType.ForgotPin:
        return await SettingsRepository.verifyPinResetOtp(
          email: OtpData.email,
          phoneNumber: OtpData.phoneNumber,
          otp: otpValue1 + otpValue2 + otpValue3 + otpValue4 + otpValue5,
        );

      default:
        return await AuthenticationRepo.verifyOTP(
          userId: OtpData.id ?? ClientProvider.readOnlyClient!.userId,
          otp: otpValue1 + otpValue2 + otpValue3 + otpValue4 + otpValue5,
        );
    }
  }

  Future<void> verifyOtp() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    log(otpValue1 + otpValue2 + otpValue3 + otpValue4 + otpValue5);

    final response = await verifyOtpRequest();
    debugPrint(response.body);

    if (!response.error) {
      Navigator.pop(context, true);
    } else {
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Incorrect otp");
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      //..Logic to show error
    }
  }

  Widget buttonWidget() {
    return CustomButton(
      buttonKey: buttonKey,
      onPressed: verifyOtp,
      label: "VERIFY",
      usesProvider: true,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.large, vertical: SizeManager.medium),
    );
  }

  Widget resendCodeWidget() {
    final TextStyle defaultStyle = TextStyle(
        fontFamily: 'Lato',
        height: 1.36,
        wordSpacing: 1.2,
        color: ColorManager.secondary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.semibold);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: defaultStyle, children: [
            if (!resendCode)
              const TextSpan(
                text: "Resend code in ",
              ),
            TextSpan(
                text: resendCode
                    ? "Resend"
                    : timerInitialized
                        ? "${60 - timerProvider.value()}s"
                        : "60s",
                style: defaultStyle.copyWith(color: ColorManager.themeColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    if (resendCode) {
                      //...Logic to resend code.
                      await AuthenticationRepo.resendOTP(
                          userId: OtpData.id!, otp: LoginData.otp!);
                      setState(() => resendCode = false);
                      timerProvider.start();
                    }
                  })
          ])),
    );
  }

  Widget descriptionWidget() {
    final TextStyle defaultStyle = TextStyle(
        fontFamily: 'Lato',
        height: 2,
        wordSpacing: 1.2,
        color: ColorManager.secondary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.semibold);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: RichText(
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "We just sent a 5-digit verification code to\n"),
          TextSpan(
              text: target,
              style: defaultStyle.copyWith(color: ColorManager.primary)),
          TextSpan(
              text: " Change your ${isEmail ? "email" : "phone number"}?",
              style: defaultStyle.copyWith(color: ColorManager.themeColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  LoginData.clear();
                  Navigator.pop(context);
                }),
        ]),
        textAlign: TextAlign.left,
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        72 + MediaQuery.of(context).viewPadding.top,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                FocusScope(
                  canRequestFocus: false,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    iconSize: 40,
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: 'back'),
                      fit: BoxFit.cover,
                      color: ColorManager.themeColor,
                      size: const Size.square(40),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  "Verify ${isEmail ? "Email" : "Phone number"}",
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

  Widget otpRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OtpInputField(
            first: true,
            onEntered: (value) {
              setState(() {
                otpValue1 = value;
              });
            },
          ),
          OtpInputField(
            onEntered: (value) {
              setState(() {
                otpValue2 = value;
              });
            },
          ),
          OtpInputField(
            onEntered: (value) {
              setState(() {
                otpValue3 = value;
              });
            },
          ),
          OtpInputField(
            onEntered: (value) {
              setState(() {
                otpValue4 = value;
              });
            },
          ),
          OtpInputField(
            last: true,
            onEntered: (value) {
              setState(() {
                otpValue5 = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
