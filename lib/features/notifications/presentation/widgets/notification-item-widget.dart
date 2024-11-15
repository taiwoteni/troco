import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/notifications/presentation/widgets/notification-item-dialog.dart';
import 'package:troco/features/notifications/utils/enums.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../domain/entities/notification.dart' as n;
import '../../../../core/components/images/svg.dart';

class NotificationItemWidget extends ConsumerStatefulWidget {
  final n.Notification notification;
  const NotificationItemWidget({super.key, required this.notification});

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
      onTap: onTap,
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
          svgRes: AssetManager.svgFile(name: "bell"),
          color: color,
          size: const Size.square(IconSizeManager.regular),
        ),
      ),
      // trailing: IconButton(
      //     onPressed: null,
      //     icon: Icon(
      //       Icons.more_vert_rounded,
      //       size: IconSizeManager.regular,
      //       color: ColorManager.primary,
      //     )),
      title: Text(widget.notification.label),
      subtitle: Text(
        widget.notification.content.replaceAll('\n', ""),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> onTap() async {
    final dialog = DialogManager(context: context);
    dialog.showDialogContent(
        icon: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.accentColor.withOpacity(0.2)),
          child: SvgIcon(
            svgRes: AssetManager.svgFile(name: "bell"),
            color: ColorManager.accentColor,
            size: const Size.square(IconSizeManager.regular),
          ),
        ),
        title: widget.notification.label,
        description: widget.notification.content,
        cancelLabel: 'Close',
        onCancel: () => context.pop());
  }

  Future<void> decline() async {
    // final response = await TransactionRepo.respondToTransaction(
    //   aprove: false,
    //   transaction: transaction, status: status)
  }
}
