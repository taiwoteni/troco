import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/notifications/presentation/widgets/notification-item-dialog.dart';
import 'package:troco/features/notifications/utils/enums.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../domain/entities/notification.dart' as n;
import '../../../../core/basecomponents/images/svg.dart';

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
    var color = widget.notification.type == NotificationType.VerifyTransaction
        ? Colors.redAccent
        : ColorManager.accentColor;
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
          svgRes: AssetManager.svgFile(
              name:
                  widget.notification.type == NotificationType.VerifyTransaction
                      ? "buy"
                      : "delivery"),
          color: color,
          size: const Size.square(IconSizeManager.regular),
        ),
      ),
      trailing: IconButton(
          onPressed: null,
          icon: Icon(
            Icons.more_vert_rounded,
            size: IconSizeManager.regular,
            color: ColorManager.primary,
          )),
      title: Text(widget.notification.label),
      subtitle: Text(
        widget.notification.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> onTap() async {
    var color = widget.notification.type == NotificationType.VerifyTransaction
        ? Colors.redAccent
        : ColorManager.accentColor;
    if (widget.notification.type == NotificationType.VerifyTransaction ||
        widget.notification.type == NotificationType.CreateTransaction) {
      log(widget.notification.argument.toString());
      // Navigator.pushNamed(context, Routes.viewTransactionRoute,
      //     arguments: Transaction.fromJson(json: widget.notification.argument));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NotificationDialog(
          icon: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.2)),
            child: SvgIcon(
              svgRes: AssetManager.svgFile(
                  name: widget.notification.type ==
                          NotificationType.VerifyTransaction
                      ? "buy"
                      : "delivery"),
              color: color,
              size: const Size.square(IconSizeManager.medium),
            ),
          ),
          title: widget.notification.label,
          description: "Do you wish to approve transaction?",
          onCancel: decline,
        );
      },
    );
  }

  Future<void> decline() async {
    // final response = await TransactionRepo.respondToTransaction(
    //   aprove: false,
    //   transaction: transaction, status: status)
  }
}
