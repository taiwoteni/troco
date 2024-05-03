import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool twoFactorEnabled = false;
  bool otpEnabled = true;
  bool automaticallyLogoutDuringInactivity = true;
  bool autoLoginPinEnabled = true;

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
        setState(() => twoFactorEnabled = !twoFactorEnabled);
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
          enabled: twoFactorEnabled,
          onChanged: (value) => setState(() => twoFactorEnabled = value)),
    );
  }

  Widget autoLogoutDuringInactivity() {
    return AnimatedOpacity(
      opacity: twoFactorEnabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!twoFactorEnabled) {
            return;
          }
          setState(() => automaticallyLogoutDuringInactivity =
              !automaticallyLogoutDuringInactivity);
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
            enabled: automaticallyLogoutDuringInactivity,
            onChanged: (value) =>
                setState(() => automaticallyLogoutDuringInactivity = value)),
      ),
    );
  }

  Widget pinMethod() {
    return AnimatedOpacity(
      opacity:
          twoFactorEnabled && automaticallyLogoutDuringInactivity ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!(twoFactorEnabled && automaticallyLogoutDuringInactivity)) {
            return;
          }
          setState(() => autoLoginPinEnabled = !autoLoginPinEnabled);
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
            onChanged: (value) => setState(() => autoLoginPinEnabled = value)),
      ),
    );
  }

  Widget passwordMethod() {
    return AnimatedOpacity(
      opacity:
          twoFactorEnabled && automaticallyLogoutDuringInactivity ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!(twoFactorEnabled && automaticallyLogoutDuringInactivity)) {
            return;
          }
          setState(() => autoLoginPinEnabled = !autoLoginPinEnabled);
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
            onChanged: (value) => setState(() => autoLoginPinEnabled = !value)),
      ),
    );
  }

  Widget loginOtpMethod() {
    return AnimatedOpacity(
      opacity: twoFactorEnabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!twoFactorEnabled) {
            return;
          }
          setState(() => otpEnabled = !otpEnabled);
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
            onChanged: (value) => setState(() => otpEnabled = value)),
      ),
    );
  }

  Widget loginPinMethod() {
    return AnimatedOpacity(
      opacity: twoFactorEnabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: ListTile(
        onTap: () {
          if (!twoFactorEnabled) {
            return;
          }
          setState(() => otpEnabled = !otpEnabled);
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
            onChanged: (value) => setState(() => otpEnabled = !value)),
      ),
    );
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
