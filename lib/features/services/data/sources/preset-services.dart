import 'package:flutter/widgets.dart';
import 'package:troco/core/app/asset-manager.dart';

import '../../../../core/app/routes-manager.dart';
import '../../../settings/data/models/settings-model.dart';
import '../../../settings/utils/enums.dart';

List<SettingsModel> presetServices({required BuildContext context}) {
  return [
    //Financial Settings.
    SettingsModel(
        label: "My Transactions",
        icon: AssetManager.svgFile(name: "transaction"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Fee Calculator",
        icon: AssetManager.svgFile(name: "calculator"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
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
    SettingsModel(
        label: "Share Troco",
        icon: AssetManager.svgFile(name: "share"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Terms and Conditions",
        icon: AssetManager.svgFile(name: "policy"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Privacy Policy",
        icon: AssetManager.svgFile(name: "policy"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
        SettingsModel(
        label: "Contact  Us",
        icon: AssetManager.svgFile(name: "audio-call"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
        SettingsModel(
        label: "About  Us",
        icon: AssetManager.svgFile(name: "about"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
  ];
}
