import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';
import '../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../groups/presentation/friends_tab/providers/friends-provider.dart';
import '../../../groups/presentation/group_tab/providers/groups-provider.dart';
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
        label: "Change Email",
        icon: AssetManager.svgFile(name: "email"),
        onTap: () => Navigator.pushNamed(context, Routes.changeEmail),
        iconType: IconType.svg),
    SettingsModel(
        label: "Change Phone Number",
        icon: CupertinoIcons.phone_fill,
        onTap: () => Navigator.pushNamed(context, Routes.changePhoneNumber),
        iconType: IconType.icon),
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
        onTap: () => {
              Share.share(
                  "Hello there! I welcome you to Troco Technology, the best escrow platform for your business. You're invited!\n\nTo get the Android or iOS app, visit our website here:\nhttps://www.troco.ng .\n\nAcknowledge this invite when registering by inputing my referall code: ${AppStorage.getUser()?.referralCode}.",
                  subject: "Welcome to Troco 🎉")
            },
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
        label: "Blocked Users",
        icon: CupertinoIcons.minus_circle_fill,
        settingsType: SettingsType.grave,
        onTap: () => Navigator.pushNamed(context, Routes.blockedUsersRoute),
        iconType: IconType.icon),
    SettingsModel(
        label: "Logout",
        icon: AssetManager.svgFile(name: "logout"),
        onTap: () async {
          final buttonKey = UniqueKey();
          final dialogService = DialogManager(context: context);
          final logout = (await dialogService.showDialogContent<bool>(
                  title: "Logout",
                  description:
                      "Are you sure you want to logout of your account?",
                  icon: ProfileIcon(
                    url: ClientProvider.readOnlyClient?.profile,
                    size: 60,
                  ),
                  cancelLabel: "Yes, Log me out",
                  cancelKey: buttonKey,
                  onCancel: () async {
                    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
                    await AppStorage.clear();
                    final friendsRefresh = ref.refresh(friendsStreamProvider);
                    final groupRefresh = ref.refresh(groupsStreamProvider);
                    final transactionRefresh =
                        ref.refresh(transactionsStreamProvider);

                    // Just to call it.
                    friendsRefresh;
                    groupRefresh;
                    transactionRefresh;
                    await Future.delayed(const Duration(seconds: 1));
                    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
                    context.pop(result: true);
                  }) ??
              false);

          if (!logout) {
            return;
          }

          ref.watch(paymentMethodProvider.notifier).state = [];
          await Navigator.pushNamedAndRemoveUntil(
              context, Routes.authRoute, (route) => false);
        },
        settingsType: SettingsType.grave,
        iconType: IconType.svg),
  ];
}
