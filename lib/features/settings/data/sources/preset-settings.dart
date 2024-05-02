import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/features/settings/utils/enums.dart';

import '../models/settings-model.dart';

List<SettingsModel> settings() {
  return [
    SettingsModel(
        label: "Edit Profile",
        icon: AssetManager.svgFile(name: "edit"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Two Factor Authentication",
        icon: AssetManager.svgFile(name: "two-factor-authentication"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Pin",
        icon: AssetManager.svgFile(name: "change-pin"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Password",
        icon: AssetManager.svgFile(name: "padlock"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Language",
        icon: AssetManager.svgFile(name: "language"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Notification Settings",
        icon: AssetManager.svgFile(name: "bell"),
        iconType: IconType.svg),
    SettingsModel(
        label: "Logout",
        icon: AssetManager.svgFile(name: "logout"),
        grave: true,
        iconType: IconType.svg),
    SettingsModel(
        label: "Delete Account",
        icon: AssetManager.svgFile(name: "trash"),
        grave: true,
        iconType: IconType.svg),
  ];
}
