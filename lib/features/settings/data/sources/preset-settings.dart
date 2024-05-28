import 'package:flutter/widgets.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import '../../utils/enums.dart';

import '../../../../core/app/routes-manager.dart';
import '../models/settings-model.dart';

List<SettingsModel> presetSettings({required BuildContext context}) {
  return [
    SettingsModel(
        label: "Edit Profile",
        icon: AssetManager.svgFile(name: "edit"),
        onTap: () => Navigator.pushNamed(context, Routes.editProfileRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Two Factor Authentication",
        icon: AssetManager.svgFile(name: "two-factor-authentication"),
        onTap: () =>
            Navigator.pushNamed(context, Routes.twoFactorAuthenticationRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Pin",
        icon: AssetManager.svgFile(name: "change-pin"),    
        onTap: ()=> Navigator.pushNamed(context, Routes.changePinRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Password",
        icon: AssetManager.svgFile(name: "padlock"),
        onTap: () => Navigator.pushNamed(context, Routes.changePasswordRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Language",
        icon: AssetManager.svgFile(name: "language"),
        onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Notification Settings",
        icon: AssetManager.svgFile(name: "bell"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Logout",
        icon: AssetManager.svgFile(name: "logout"),
        onTap: (){
          AppStorage.clear();
          Navigator.pushNamedAndRemoveUntil(context, Routes.authRoute, (route) => false);
        },
        grave: true,
        iconType: IconType.svg),
    SettingsModel(
        label: "Delete Account",
        icon: AssetManager.svgFile(name: "trash"),
        grave: true,
        iconType: IconType.svg),
  ];
}
