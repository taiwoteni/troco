import 'package:flutter/services.dart';

import 'color-manager.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  static SystemUiOverlayStyle previousUiOverlayStyle = getHomeUiOverlayStyle();
  static ThemeData getApplicationTheme() {
    return ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: ColorManager.themeColor,
      primaryColorDark: ColorManager.primary,
      primaryColorLight: ColorManager.secondary,
      disabledColor: ColorManager.tertiary,
    );
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarColor: ColorManager.background,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getOnboardingUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarColor: ColorManager.background,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getSplashUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: ColorManager.themeColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.themeColor,
        systemNavigationBarIconBrightness: Brightness.light);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getGroupsUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getWalletUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getChatUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getTransactionScreenUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }

  static SystemUiOverlayStyle getHomeUiOverlayStyle() {
    previousUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
    return previousUiOverlayStyle!;
  }
}
