import 'package:flutter/services.dart';

import 'color-manager.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeData getApplicationTheme() {
    return ThemeData.light().copyWith(
      useMaterial3: true,
      primaryColor: ColorManager.themeColor,
      primaryColorDark: ColorManager.primary,
      primaryColorLight: ColorManager.secondary,
      disabledColor: ColorManager.tertiary,
    );
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle() {
    return SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarColor: ColorManager.background,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.background,
        systemNavigationBarIconBrightness: Brightness.dark);
  }

  static SystemUiOverlayStyle getSplashUiOverlayStyle() {
    return SystemUiOverlayStyle.light.copyWith(
        statusBarColor: ColorManager.themeColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.themeColor,
        systemNavigationBarIconBrightness: Brightness.light);
  }
}
