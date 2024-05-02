
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/settings/data/models/settings-model.dart';
import 'package:troco/features/settings/presentation/settings-page/utils/enums.dart';

class SettingsTileWidget extends StatelessWidget {
  final SettingsModel setting;
  const SettingsTileWidget({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium * 1.5,
          vertical: SizeManager.small * 0.5),
      leading: leading(),
      trailing: trailing(),
      horizontalTitleGap: SizeManager.large,
      title: Text(setting.label),
      titleTextStyle: TextStyle(
          color: setting.grave ? Colors.red.shade600 : ColorManager.primary,
          fontFamily: 'quicksand',
          overflow: TextOverflow.ellipsis,
          fontSize: FontSizeManager.regular * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget leading() {
    return Container(
      width: IconSizeManager.large,
      height: IconSizeManager.large,
      decoration: BoxDecoration(
          color: setting.grave
              ? Colors.red.shade600.withOpacity(0.1)
              : ColorManager.accentColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(SizeManager.regular)),
      alignment: Alignment.center,
      child: setting.iconType == IconType.icon
          ? Icon(
              setting.icon as IconData,
              color: setting.grave
                  ? Colors.red.shade600
                  : ColorManager.accentColor,
              size: IconSizeManager.regular * 1.2,
            )
          : SvgIcon(
              svgRes: setting.icon,
              color: setting.grave
                  ? Colors.red.shade600
                  : ColorManager.accentColor,
              size: const Size.square(IconSizeManager.regular * 1.2),
            ),
    );
  }

  Widget trailing() {
    return Container(
      width: IconSizeManager.medium * 1.3,
      height: IconSizeManager.medium * 1.3,
      decoration: BoxDecoration(
          color: setting.grave
              ? Colors.red.shade600.withOpacity(0.1)
              : ColorManager.accentColor.withOpacity(0.07),
          shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: setting.grave ? Colors.red.shade600 : ColorManager.accentColor,
        size: IconSizeManager.regular * 0.9,
      ),
    );
  }
}
