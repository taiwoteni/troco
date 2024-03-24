// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/lottie.dart';
import 'package:troco/providers/client-provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool showLoading = false;

  @override
  void initState() {
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
          context, isLoggedIn ? Routes.homeRoute : Routes.authRoute);
    });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetManager.imageFile(name: "troco"),
              width: 300,
              height: 80,
            ),
            Visibility(
              visible: true,
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
