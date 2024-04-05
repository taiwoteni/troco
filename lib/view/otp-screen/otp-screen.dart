import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/otp-input-field.dart';
import 'package:troco/data/login-data.dart';
import 'package:troco/providers/button-provider.dart';
import 'package:troco/providers/timer-provider.dart';

import '../../app/asset-manager.dart';
import '../../app/color-manager.dart';
import '../../app/font-manager.dart';
import '../../app/size-manager.dart';
import '../../custom-views/spacer.dart';
import '../../custom-views/svg.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final bool isFromLogin;
  const OTPScreen({super.key, required this.isFromLogin});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final UniqueKey buttonKey = UniqueKey();
  late bool isEmail;
  bool timerIntialized = false;
  bool resendCode = false;
  late TimerProvider timerProvider;

  String otpValue1 = "",
      otpValue2 = "",
      otpValue3 = "",
      otpValue4 = "",
      otpValue5 = "";

  @override
  void dispose() {
    LoginData.clear();
    if (timerIntialized) {
      timerProvider.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    /// We don't need to check if phone number is empty
    /// because whenever we navigate to login screen, Login Data is cleared.
    /// And it is from login screen that we come to OTPScreen with the [isFromLogin] argument
    /// being true.

    bool emailNull = LoginData.email == null;
    bool emailEmpty = emailNull ? true : LoginData.email!.trim().isEmpty;
    isEmail = widget.isFromLogin ? !emailEmpty : false;
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

      setState(() => timerIntialized = true);

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

  Widget buttonWidget() {
    return CustomButton(
      buttonKey: buttonKey,
      onPressed: () {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        Future.delayed(const Duration(seconds: 5)).then((value) {
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          if (widget.isFromLogin) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.authSuccessRoute, (route) => false);
          } else {
            Navigator.pushReplacementNamed(context, Routes.setupAccountRoute);
          }
        });
      },
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
                    : timerIntialized
                        ? "${60 - timerProvider.value()}s"
                        : "60s",
                style: defaultStyle.copyWith(color: ColorManager.themeColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (resendCode) {
                      //...Logic to resend code.
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
              text: isEmail ? LoginData.email : LoginData.phoneNumber,
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
      preferredSize: const Size.fromHeight(72),
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
