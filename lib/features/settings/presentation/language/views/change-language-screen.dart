import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';

class ChangeLanguageScreen extends ConsumerStatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends ConsumerState<ChangeLanguageScreen> {
  bool englishLanguage = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        appBar: appBar(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              largeSpacer(),
              sectionText(text: "Choose Language"),
              regularSpacer(),
              englishTile(),
              divider(),
              frenchTile(),
            ],
          ),
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

  Widget frenchTile() {
    return ListTile(
      onTap: () {
        setState(() => englishLanguage = !englishLanguage);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          vertical: SizeManager.regular, horizontal: SizeManager.medium),
      horizontalTitleGap: SizeManager.large,
      leading: leading(subAssetString: "language"),
      title: const Text("French"),
      titleTextStyle: TextStyle(
          color: ColorManager.primary,
          fontFamily: 'quicksand',
          overflow: TextOverflow.ellipsis,
          fontSize: FontSizeManager.regular * 1.2,
          fontWeight: FontWeightManager.extrabold),
      trailing: switchWidget(
          enabled: !englishLanguage,
          onChanged: (value) => setState(() => englishLanguage = !value)),
    );
  }

  Widget englishTile() {
    return ListTile(
      onTap: () {
        setState(() => englishLanguage = !englishLanguage);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          vertical: SizeManager.regular, horizontal: SizeManager.medium),
      horizontalTitleGap: SizeManager.large,
      leading: leading(subAssetString: "language"),
      title: const Text("English"),
      titleTextStyle: TextStyle(
          color: ColorManager.primary,
          fontFamily: 'quicksand',
          overflow: TextOverflow.ellipsis,
          fontSize: FontSizeManager.regular * 1.2,
          fontWeight: FontWeightManager.extrabold),
      trailing: switchWidget(
          enabled: englishLanguage,
          onChanged: (value) => setState(() => englishLanguage = value)),
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
                  "Change Language",
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
