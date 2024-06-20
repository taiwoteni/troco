import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/settings/domain/entity/settings.dart';
import 'package:troco/features/settings/presentation/settings-page/providers/settings-provider.dart';
import 'package:troco/features/settings/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';

class TwoFactorAuthenticationScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthenticationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState
    extends ConsumerState<TwoFactorAuthenticationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            largeSpacer(),
            sectionText(text: "Enable Two Factor"),
            regularSpacer(),
            enableTwoFactorAuthentication(),
            extraLargeSpacer(),
            sectionText(text: "Login Two-Factor Method"),
            regularSpacer(),
            loginOtpMethod(),
            divider(),
            loginPinMethod(),
            extraLargeSpacer(),
            sectionText(text: "App Inactivity"),
            regularSpacer(),
            autoLogoutDuringInactivity(),
            extraLargeSpacer(),
            sectionText(text: "App Entry Method"),
            regularSpacer(),
            pinMethod(),
            divider(),
            passwordMethod()
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      endIndent: SizeManager.large,
      color: ColorManager.secondary.withOpacity(0.09),
      indent: SizeManager.large,
    );
  }

  Widget sectionText({required final String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      child: InfoText(
        text: text,
        color: ColorManager.accentColor,
        fontSize: FontSizeManager.regular * 0.9,
        fontWeight: FontWeightManager.semibold,
      ),
    );
  }

  Widget enableTwoFactorAuthentication() {
    return ListTile(
        onTap: () {
          final settingsJson = ref.read(settingsProvider).toJson();
          settingsJson["two-factor-enabled"] =
              !ref.watch(settingsProvider).twoFactorEnabled;
          ref.watch(settingsProvider.notifier).state =
              Settings.fromJson(map: settingsJson);
          AppStorage.saveSettings(
              settings: Settings.fromJson(map: settingsJson));
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
            vertical: SizeManager.regular, horizontal: SizeManager.medium),
        horizontalTitleGap: SizeManager.large,
        leading: leading(subAssetString: "two-factor-authentication"),
        title: const Text("Two Factor Authentication"),
        titleTextStyle: TextStyle(
            color: ColorManager.primary,
            fontFamily: 'quicksand',
            overflow: TextOverflow.ellipsis,
            fontSize: FontSizeManager.regular * 1.2,
            fontWeight: FontWeightManager.extrabold),
        trailing: switchWidget(
          enabled: ref.watch(settingsProvider).twoFactorEnabled,
          onChanged: (value) {
            final settingsJson = ref.read(settingsProvider).toJson();
            settingsJson["two-factor-enabled"] = value;
            ref.watch(settingsProvider.notifier).state =
                Settings.fromJson(map: settingsJson);
            AppStorage.saveSettings(
                settings: Settings.fromJson(map: settingsJson));
          },
        ));
  }

  Widget autoLogoutDuringInactivity() {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
          onTap: () {
            final settingsJson = ref.read(settingsProvider).toJson();
            settingsJson["auto-logout"] =
                !ref.read(settingsProvider).autoLogout;
            ref.watch(settingsProvider.notifier).state =
                Settings.fromJson(map: settingsJson);
            AppStorage.saveSettings(
                settings: Settings.fromJson(map: settingsJson));
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
              vertical: SizeManager.regular, horizontal: SizeManager.medium),
          horizontalTitleGap: SizeManager.large,
          leading: leading(subAssetString: "logout"),
          title: const Text("Auto Logout after Inactivity"),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              overflow: TextOverflow.ellipsis,
              fontSize: FontSizeManager.regular * 1.2,
              fontWeight: FontWeightManager.extrabold),
          trailing: switchWidget(
            enabled: ref.watch(settingsProvider).autoLogout,
            onChanged: (value) {
              final settingsJson = ref.read(settingsProvider).toJson();
              settingsJson["auto-logout"] = value;
              ref.watch(settingsProvider.notifier).state =
                  Settings.fromJson(map: settingsJson);
              AppStorage.saveSettings(
                  settings: Settings.fromJson(map: settingsJson));
            },
          )),
    );
  }

  Widget pinMethod() {
    final automaticallyLogoutDuringInactivity =
        ref.watch(settingsProvider).autoLogout;
    final autoLoginPinEnabled =
        ref.watch(settingsProvider).appEntryMethod == AppEntryMethod.Pin;
    return AnimatedOpacity(
        opacity: automaticallyLogoutDuringInactivity ? 1 : 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        child: ListTile(
          onTap: () {
            if (!automaticallyLogoutDuringInactivity) {
              return;
            }
            final settingsJson = ref.read(settingsProvider).toJson();
            settingsJson["app-entry-method"] =
                autoLoginPinEnabled ? "password" : "pin";
            ref.watch(settingsProvider.notifier).state =
                Settings.fromJson(map: settingsJson);
            AppStorage.saveSettings(
                settings: Settings.fromJson(map: settingsJson));
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
              vertical: SizeManager.regular, horizontal: SizeManager.medium),
          horizontalTitleGap: SizeManager.large,
          leading: leading(subAssetString: "change-pin"),
          title: const Text("Transaction Pin"),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              overflow: TextOverflow.ellipsis,
              fontSize: FontSizeManager.regular * 1.2,
              fontWeight: FontWeightManager.extrabold),
          trailing: switchWidget(
            enabled: autoLoginPinEnabled,
            onChanged: (value) {
              if (automaticallyLogoutDuringInactivity) {
                final settingsJson = ref.read(settingsProvider).toJson();
                settingsJson["app-entry-method"] =
                    autoLoginPinEnabled ? "password" : "pin";
                ref.watch(settingsProvider.notifier).state =
                    Settings.fromJson(map: settingsJson);
                AppStorage.saveSettings(
                    settings: Settings.fromJson(map: settingsJson));
              }
            },
          ),
        ));
  }

  Widget passwordMethod() {
    final automaticallyLogoutDuringInactivity =
        ref.watch(settingsProvider).autoLogout;
    final autoLoginPinEnabled =
        ref.watch(settingsProvider).appEntryMethod == AppEntryMethod.Pin;
    return AnimatedOpacity(
      opacity: automaticallyLogoutDuringInactivity ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!automaticallyLogoutDuringInactivity) {
            return;
          }
          final settingsJson = ref.read(settingsProvider).toJson();
          settingsJson["app-entry-method"] =
              autoLoginPinEnabled ? "password" : "pin";
          ref.watch(settingsProvider.notifier).state =
              Settings.fromJson(map: settingsJson);
          AppStorage.saveSettings(
              settings: Settings.fromJson(map: settingsJson));
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
            vertical: SizeManager.regular, horizontal: SizeManager.medium),
        horizontalTitleGap: SizeManager.large,
        leading: leading(subAssetString: "padlock"),
        title: const Text("Password"),
        titleTextStyle: TextStyle(
            color: ColorManager.primary,
            fontFamily: 'quicksand',
            overflow: TextOverflow.ellipsis,
            fontSize: FontSizeManager.regular * 1.2,
            fontWeight: FontWeightManager.extrabold),
        trailing: switchWidget(
          enabled: !autoLoginPinEnabled,
          onChanged: (value) {
            if (automaticallyLogoutDuringInactivity) {
              final settingsJson = ref.read(settingsProvider).toJson();
              settingsJson["app-entry-method"] =
                  autoLoginPinEnabled ? "password" : "pin";
              ref.watch(settingsProvider.notifier).state =
                  Settings.fromJson(map: settingsJson);
              AppStorage.saveSettings(
                  settings: Settings.fromJson(map: settingsJson));
            }
          },
        ),
      ),
    );
  }

  Widget loginOtpMethod() {
    final twoFactorEnabled = ref.watch(settingsProvider).twoFactorEnabled;
    final otpEnabled =
        ref.watch(settingsProvider).twoFactorMethod == TwoFactorMethod.Otp;
    return AnimatedOpacity(
      opacity: twoFactorEnabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
          onTap: () {
            if (!twoFactorEnabled) {
              return;
            }
            final settingsJson = ref.read(settingsProvider).toJson();
            settingsJson["two-factor-method"] = !otpEnabled ? "otp" : "pin";
            ref.watch(settingsProvider.notifier).state =
                Settings.fromJson(map: settingsJson);
            AppStorage.saveSettings(
                settings: Settings.fromJson(map: settingsJson));
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
              vertical: SizeManager.regular, horizontal: SizeManager.medium),
          horizontalTitleGap: SizeManager.large,
          leading: leading(subAssetString: "otp"),
          title: const Text("Otp Authentication"),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              overflow: TextOverflow.ellipsis,
              fontSize: FontSizeManager.regular * 1.2,
              fontWeight: FontWeightManager.extrabold),
          trailing: switchWidget(
              enabled: otpEnabled,
              onChanged: (value) {
                if (!twoFactorEnabled) {
                  return;
                }
                final settingsJson = ref.read(settingsProvider).toJson();
                settingsJson["two-factor-method"] = !otpEnabled ? "otp" : "pin";
                ref.watch(settingsProvider.notifier).state =
                    Settings.fromJson(map: settingsJson);
                AppStorage.saveSettings(
                    settings: Settings.fromJson(map: settingsJson));
              })),
    );
  }

  Widget loginPinMethod() {
    final twoFactorEnabled = ref.watch(settingsProvider).twoFactorEnabled;
    final otpEnabled =
        ref.watch(settingsProvider).twoFactorMethod == TwoFactorMethod.Otp;

    return AnimatedOpacity(
        opacity: twoFactorEnabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        child: ListTile(
          onTap: () {
            if (!twoFactorEnabled) {
              return;
            }
            final settingsJson = ref.read(settingsProvider).toJson();
            settingsJson["two-factor-method"] = !otpEnabled ? "otp" : "pin";
            ref.watch(settingsProvider.notifier).state =
                Settings.fromJson(map: settingsJson);
            AppStorage.saveSettings(
                settings: Settings.fromJson(map: settingsJson));
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
              vertical: SizeManager.regular, horizontal: SizeManager.medium),
          horizontalTitleGap: SizeManager.large,
          leading: leading(subAssetString: "change-pin"),
          title: const Text("Transaction Pin"),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              overflow: TextOverflow.ellipsis,
              fontSize: FontSizeManager.regular * 1.2,
              fontWeight: FontWeightManager.extrabold),
          trailing: switchWidget(
            enabled: !otpEnabled,
            onChanged: (value) {
              if (!twoFactorEnabled) {
                return;
              }
              final settingsJson = ref.read(settingsProvider).toJson();
              settingsJson["two-factor-method"] = !otpEnabled ? "otp" : "pin";
              ref.watch(settingsProvider.notifier).state =
                  Settings.fromJson(map: settingsJson);
              AppStorage.saveSettings(
                  settings: Settings.fromJson(map: settingsJson));
            },
          ),
        ));
  }

  Widget leading({required final String subAssetString}) {
    return Container(
      width: IconSizeManager.large,
      height: IconSizeManager.large,
      decoration: BoxDecoration(
          color: ColorManager.accentColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(SizeManager.regular)),
      alignment: Alignment.center,
      child: SvgIcon(
        svgRes: AssetManager.svgFile(name: subAssetString),
        color: ColorManager.accentColor,
        size: const Size.square(IconSizeManager.regular * 1.2),
      ),
    );
  }

  Widget switchWidget(
      {required bool enabled,
      required final void Function(bool value) onChanged}) {
    final color = ColorManager.secondaryDark;
    return Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: enabled,
        inactiveTrackColor: color,
        inactiveThumbColor: ColorManager.background,
        activeColor: ColorManager.background,
        activeTrackColor: ColorManager.accentColor,
        trackOutlineColor: MaterialStatePropertyAll(
            enabled ? ColorManager.accentColor : color),
        onChanged: onChanged);
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(72 + MediaQuery.of(context).viewPadding.top),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Two Factor Authentication",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
