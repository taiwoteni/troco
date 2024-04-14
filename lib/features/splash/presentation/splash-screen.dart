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
import 'package:troco/core/basecomponents/animations/lottie.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

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
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSplashUiOverlayStyle());
      await Future.delayed(const Duration(seconds: 4));
      setState(() {
        showLoading = true;
      });

      await Future.delayed(const Duration(seconds: 5));
      final isLoggedIn = ref.watch(ClientProvider.userProvider) != null;
      Navigator.pushReplacementNamed(
          context, isLoggedIn ? Routes.homeRoute : Routes.onBoardingRoute);
    });
  }

  void requestPermission() async {
    // TODO: ALSO MAKE SURE THAT THESE PERMISSIONS ARE SPECIFIED IN Info.Plist
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.microphone,
      Permission.contacts
    ].request();
    log(permissions.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.themeColor,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: ColorManager.themeColor,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              AssetManager.imageFile(
                name: "troco-white",
              ),
              width: 200,
              height: 40,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 50,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 5000),
                opacity: showLoading ? 1 : 0,
                curve: Curves.ease,
                child: LottieWidget(
                  lottieRes: AssetManager.lottieFile(name: 'loading'),
                  size: const Size.square(IconSizeManager.large),
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
