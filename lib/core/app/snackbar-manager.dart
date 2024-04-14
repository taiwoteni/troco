import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';

class SnackbarManager {
  static void showBasicSnackbar({
    required final BuildContext context,
    required final String message,
    int seconds = 2,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontFamily: "Lato",
          color: ColorManager.primaryDark,
          fontSize: FontSizeManager.medium * 0.8,
          fontWeight: FontWeightManager.medium,
        ),
      ),
      dismissDirection: DismissDirection.startToEnd,
      // margin: const EdgeInsets.symmetric(
      //     horizontal: SizeManager.regular, vertical: SizeManager.medium),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      backgroundColor: ColorManager.accentColor,
      duration: Duration(seconds: seconds),
      onVisible: () async{
        SystemChrome.setSystemUIOverlayStyle(ThemeManager.previousUiOverlayStyle!.copyWith(
          systemNavigationBarColor: ColorManager.accentColor,
          systemNavigationBarIconBrightness: Brightness.light
          ));
        await Future.delayed(Duration(seconds: seconds));
        SystemChrome.setSystemUIOverlayStyle(ThemeManager.previousUiOverlayStyle!);

      },
    ));
  }
}
