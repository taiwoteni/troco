import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import '../../utils/enums.dart';

import '../../../../core/app/routes-manager.dart';
import '../models/settings-model.dart';

List<SettingsModel> presetSettings(
    {required BuildContext context, required final WidgetRef ref}) {
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
        onTap: () => Navigator.pushNamed(context, Routes.changePinRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Password",
        icon: AssetManager.svgFile(name: "padlock"),
        onTap: () => Navigator.pushNamed(context, Routes.changePasswordRoute),
        iconType: IconType.svg),
    SettingsModel(
        label: "Share Troco",
        icon: AssetManager.svgFile(name: "share"),
        settingsType: SettingsType.financial,
        // onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
        iconType: IconType.svg),
    // SettingsModel(
    //     label: "Change Language",
    //     icon: AssetManager.svgFile(name: "language"),
    //     onTap: () => Navigator.pushNamed(context, Routes.changeLanguageRoute),
    //     iconType: IconType.svg),
    // SettingsModel(
    //     label: "Notification Settings",
    //     icon: AssetManager.svgFile(name: "bell"),
    //     iconType: IconType.svg),

    //Grave Settings
    SettingsModel(
        label: "Logout",
        icon: AssetManager.svgFile(name: "logout"),
        onTap: () async {
          ref.watch(paymentMethodProvider.notifier).state = [];
          await Navigator.pushNamedAndRemoveUntil(
              context, Routes.authRoute, (route) => false);
        },
        settingsType: SettingsType.grave,
        iconType: IconType.svg),
  ];
}
