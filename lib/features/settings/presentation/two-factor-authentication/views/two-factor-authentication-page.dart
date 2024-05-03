import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';

class TwoFactorAuthenticationPage extends ConsumerStatefulWidget {
  const TwoFactorAuthenticationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState extends ConsumerState<TwoFactorAuthenticationPage> {
  bool twoFactorEnabled = false;

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
            enableTwoFactorAuthentication(),
          ],
        ),
      ),
    );
  }

  Widget enableTwoFactorAuthentication() {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          vertical: SizeManager.small, horizontal: SizeManager.medium),
      horizontalTitleGap: SizeManager.large,
      title: const Text("Enable Two Factor Authentication"),
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

  Widget switchWidget(
      {required bool enabled,
      required final void Function(bool value) onChanged}) {
    return Switch(
        value: enabled,
        inactiveTrackColor: ColorManager.secondary,
        inactiveThumbColor: ColorManager.background,
        activeColor: ColorManager.background,
        activeTrackColor: ColorManager.accentColor,
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
