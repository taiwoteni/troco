import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/settings/data/models/settings-model.dart';
import '../../../utils/enums.dart';

class SettingsTileWidget extends StatelessWidget {
  final SettingsModel setting;
  const SettingsTileWidget({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: setting.onTap,
      dense: true,
      splashColor: ColorManager.tertiary,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium * 1.5,
          vertical: SizeManager.small * 0.5),
      leading: leading(),
      trailing: trailing(),
      horizontalTitleGap: SizeManager.large,
      title: Text(setting.label),
      titleTextStyle: TextStyle(
          color: setting.settingsType == SettingsType.grave
              ? Colors.red.shade600
              : ColorManager.primary,
          fontFamily: 'quicksand',
          overflow: TextOverflow.ellipsis,
          fontSize: FontSizeManager.regular * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Color settingsPrimaryColor() {
    switch (setting.settingsType) {
      case SettingsType.normal:
        return ColorManager.accentColor;
      case SettingsType.financial:
        return Colors.purple.shade700;
      default:
        return Colors.red.shade600;
    }
  }

  Color settingsSecondaryColor() {
    switch (setting.settingsType) {
      case SettingsType.normal:
        return ColorManager.accentColor.withOpacity(0.07);
      case SettingsType.financial:
        return Colors.purple.withOpacity(0.2);
      default:
        return Colors.red.shade600.withOpacity(0.1);
    }
  }

  Widget leading() {
    return Container(
      width: IconSizeManager.large,
      height: IconSizeManager.large,
      decoration: BoxDecoration(
          color: settingsSecondaryColor(),
          borderRadius: BorderRadius.circular(SizeManager.regular)),
      alignment: Alignment.center,
      child: setting.iconType == IconType.icon
          ? Icon(
              setting.icon as IconData,
              color: settingsPrimaryColor(),
              size: IconSizeManager.regular * 1.2,
            )
          : SvgIcon(
              svgRes: setting.icon,
              color: settingsPrimaryColor(),
              size: const Size.square(IconSizeManager.regular * 1.2),
            ),
    );
  }

  Widget trailing() {
    return Container(
      width: IconSizeManager.medium * 1.3,
      height: IconSizeManager.medium * 1.3,
      decoration: BoxDecoration(
          color: settingsSecondaryColor(), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: settingsPrimaryColor(),
        size: IconSizeManager.regular * 0.9,
      ),
    );
  }
}
