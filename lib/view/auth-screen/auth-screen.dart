import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/lottie.dart';
import 'package:troco/custom-views/spacer.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSystemUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.background,
      body: Container(
        color: ColorManager.background,
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    child: LottieWidget(
                      lottieRes: AssetManager.lottieFile(name: "welcome"),
                      size: const Size(
                        double.maxFinite,
                        SizeManager.extralarge * 5.7,
                      ),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  Text(
                    "TO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: FontSizeManager.extralarge,
                      fontWeight: FontWeightManager.bold,
                      color: ColorManager.primary,
                    ),
                  ),
                  largeSpacer(),
                  regularSpacer(),
                  Align(
                    child: Image.asset(
                      AssetManager.iconFile(name: 'troco-green'),
                      width: double.maxFinite,
                      fit: BoxFit.contain,
                      height: IconSizeManager.large,
                    ),
                  ),
                  mediumSpacer(),
                  Text(
                    "It is a long established fact with a\nreadable content of a page when\n looking at its layout.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.medium,
                      height: 1.36,
                      wordSpacing: 1.2,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),
            ),
            authButtons(),
          ],
        ),
      ),
    );
  }

  Widget authButtons() {
    return Padding(
      padding: const EdgeInsets.only(
          left: SizeManager.regular,
          right: SizeManager.regular,
          bottom: SizeManager.extralarge),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.registerRoute),
              child: Container(
                height: SizeManager.extralarge * 2,
                margin: const EdgeInsets.symmetric(
                    horizontal: SizeManager.regular,
                    vertical: SizeManager.medium),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeManager.regular * 1.2),
                    color: ColorManager.themeColor),
                alignment: Alignment.center,
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                      color: ColorManager.primaryDark,
                      fontSize: FontSizeManager.large * 0.8,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.loginRoute),
              child: Container(
                height: SizeManager.extralarge * 2,
                margin: const EdgeInsets.symmetric(
                    horizontal: SizeManager.regular,
                    vertical: SizeManager.medium),
                decoration: BoxDecoration(
                    border: Border.fromBorderSide(BorderSide(
                      color: ColorManager.themeColor,
                      width: 2,
                    )),
                    borderRadius:
                        BorderRadius.circular(SizeManager.regular * 1.2),
                    color: ColorManager.background),
                alignment: Alignment.center,
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                      color: ColorManager.themeColor,
                      fontSize: FontSizeManager.large * 0.8,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
