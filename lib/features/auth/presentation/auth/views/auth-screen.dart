import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/app/value-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../../core/components/others/spacer.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) async{
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSystemUiOverlayStyle());
      ref.read(clientProvider.notifier).state = null;
      await AppStorage.clear();
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
                  Expanded(
                    flex: 7,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        AssetManager.imageFile(name: 'welcome'),
                        width: IconSizeManager.extralarge * 3.7,
                        fit: BoxFit.cover,
                        height: IconSizeManager.extralarge * 3.7,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "WELCOME TO",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: FontSizeManager.large,
                              fontWeight: FontWeightManager.extrabold,
                              color: ColorManager.primary,
                            ),
                          ),
                          largeSpacer(),
                          Align(
                            child: Image.asset(
                              AssetManager.imageFile(name: 'troco'),
                              width: double.maxFinite,
                              fit: BoxFit.contain,
                              height: IconSizeManager.large * 0.7,
                            ),
                          ),
                          largeSpacer(),
                          Text(
                            ValuesManager.welcomeString,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeightManager.medium,
                              color: ColorManager.secondary,
                              fontSize: FontSizeManager.medium * 0.9,
                              height: 1.36,
                              wordSpacing: 1.2,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ],
                      ),
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
