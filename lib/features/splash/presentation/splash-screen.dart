// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/settings/presentation/settings-page/providers/settings-provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static late double receiptViewInsetsTop;
  static late double receiptViewWatermarkWidth;
  static late double receiptViewHorizontalMargin;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool showLoading = false;

  @override
  void initState() {
    requestPermission();
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      SplashScreen.receiptViewInsetsTop =
          MediaQuery.viewInsetsOf(context).top.toDouble();
      SplashScreen.receiptViewHorizontalMargin =
          (MediaQuery.sizeOf(context).width * .09).toDouble();
      SplashScreen.receiptViewWatermarkWidth =
          (MediaQuery.sizeOf(context).width * 4).toDouble();
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSplashUiOverlayStyle());
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        showLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));
      final isLoggedIn = ClientProvider.readOnlyClient != null;
      Navigator.pushReplacementNamed(
          context,
          isLoggedIn
              ? (ref.watch(settingsProvider).autoLogout
                  ? Routes.welcomeBackRoute
                  : (ref.watch(clientProvider)!.blocked
                      ? Routes.blockedScreenRoute
                      : Routes.homeRoute))
              : Routes.onBoardingRoute);
    });
  }

  void requestPermission() async {
    // TODO: ALSO MAKE SURE THAT THESE PERMISSIONS ARE SPECIFIED IN Info.Plist
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.accessMediaLocation,
      Permission.microphone,
    ].request();
    log(permissions.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorManager.themeColor,
          body: Stack(
            children: [
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: ColorManager.themeColor,
                alignment: Alignment.center,
                child: Image.asset(
                  AssetManager.imageFile(
                    name: "troco-white",
                  ),
                  width: 200,
                  height: 40,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.transparent,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: SizeManager.extralarge * 1.5),
          child: Transform.translate(
            offset: Offset(-(SizeManager.extralarge / 1.5), 0),
            child: LottieWidget(
              //duration of this lottie is 3 secs
              lottieRes: AssetManager.lottieFile(name: 'loading-label'),
              color: Colors.white,
              size: const Size.square(SizeManager.extralarge * 2.1),
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }
}
