import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/images/svg.dart';

class NotificationItemWidget extends ConsumerStatefulWidget {
  const NotificationItemWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationItemWidgetState();
}

class _NotificationItemWidgetState
    extends ConsumerState<NotificationItemWidget> {
  @override
  Widget build(BuildContext context) {
    var color = ColorManager.accentColor;
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(
          vertical: SizeManager.small, horizontal: SizeManager.medium),
      horizontalTitleGap: SizeManager.medium * 0.5,
      titleTextStyle: TextStyle(
          color: ColorManager.primary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.semibold),
      subtitleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.secondary,
          fontFamily: 'Quicksand',
          fontSize: FontSizeManager.regular,
          fontWeight: FontWeightManager.regular),
      leading: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withOpacity(0.2)),
        child: SvgIcon(
          svgRes: AssetManager.svgFile(name: "delivery"),
          color: color,
          size: const Size.square(IconSizeManager.regular),
        ),
      ),
      title: const Text("Transaction"),
      subtitle: const Text(
        "'Service..' now has an Admin.",
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
