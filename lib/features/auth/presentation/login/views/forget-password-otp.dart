import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/basecomponents/animations/lottie.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../../../../core/basecomponents/texts/inputs/otp-input-field.dart';
import '../../../../../core/basecomponents/others/spacer.dart';
import '../../../../../core/basecomponents/images/svg.dart';
import '../../../data/models/login-data.dart';
import '../../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../otp/providers/timer-provider.dart';

class OTPForgetPasswordScreen extends ConsumerStatefulWidget {
  final bool isFromLogin = true;
  const OTPForgetPasswordScreen({super.key});

  @override
  ConsumerState<OTPForgetPasswordScreen> createState() =>
      _OTPForgetPasswordScreenState();
}

class _OTPForgetPasswordScreenState
    extends ConsumerState<OTPForgetPasswordScreen> {
  final UniqueKey buttonKey = UniqueKey();
  late bool isEmail;
  bool timerIntialized = false;
  bool resetPassword = false;
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
    /// And it is from login screen that we come to OTPForgetPasswordScreen.The [isFromLogin] argument
    /// being true.
    bool emailNull = LoginData.email == null;
    bool emailEmpty = emailNull ? true : LoginData.email!.trim().isEmpty;
    isEmail = !emailEmpty;
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
    return resetPassword
        ? const ResetComplete()
        : Padding(
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
                          "Verify ${isEmail ? "Email" : "Phone Number"}",
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
          setState(() => resetPassword = true);
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
          const TextSpan(
              text:
                  "Before we reset your password,\nWe just sent a 5-digit verification code to\n"),
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
                  "Reset ${isEmail ? "Email" : "Phone number"}",
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

class ResetComplete extends StatefulWidget {
  const ResetComplete({super.key});

  @override
  State<ResetComplete> createState() => _ResetCompleteState();
}

class _ResetCompleteState extends State<ResetComplete> {
  @override
  Widget build(BuildContext context) {
    Widget backButton() {
      return Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.regular,
            right: SizeManager.regular,
            bottom: SizeManager.extralarge),
        child: CustomButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          label: "BACK",
          margin: const EdgeInsets.symmetric(
              horizontal: SizeManager.regular, vertical: SizeManager.medium),
        ),
      );
    }

    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: ColorManager.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieWidget(
                  lottieRes: AssetManager.lottieFile(name: "reset"),
                  size: const Size.square(IconSizeManager.extralarge * 2),
                  loop: true,
                  color: ColorManager.accentColor,
                ),
                mediumSpacer(),
                Text(
                  "Password Reset Complete.",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.semibold,
                      fontSize: FontSizeManager.large * 0.8),
                ),
              ],
            ),
          ),
          backButton(),
        ],
      ),
    );
  }
}
