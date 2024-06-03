import 'package:flutter/widgets.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import '../../utils/enums.dart';

import '../../../../core/app/routes-manager.dart';
import '../models/settings-model.dart';

List<SettingsModel> presetSettings({required BuildContext context}) {
  return [

    //Normal Settings
    //settingType is normal by default so it can be omitted
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

    //Financial Settings.
    SettingsModel(
        label: "Payment Methods",
        icon: AssetManager.svgFile(name: "payment"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "KYC Verification",
        icon: AssetManager.svgFile(name: "verification"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),

    //Grave Settings    
    SettingsModel(
        label: "Logout",
        icon: AssetManager.svgFile(name: "logout"),
        onTap: (){
          AppStorage.clear();
          Navigator.pushNamedAndRemoveUntil(context, Routes.authRoute, (route) => false);
        },
        settingsType: SettingsType.grave,
        iconType: IconType.svg),
    SettingsModel(
        label: "Delete Account",
        icon: AssetManager.svgFile(name: "trash"),
        settingsType: SettingsType.grave,
        iconType: IconType.svg),
  ];
}
