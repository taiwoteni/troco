import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';

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
  final buttonKey = UniqueKey();
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
      trailing: widget.notification.read
          ? null
          : Container(
              width: 7,
              margin: EdgeInsets.only(right: SizeManager.regular),
              height: 7,
              decoration: BoxDecoration(
                  color: ColorManager.accentColor, shape: BoxShape.circle),
            ),
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
        okLabel: !widget.notification.read ? 'Mark as read' : null,
        cancelKey: buttonKey,
        okKey: buttonKey,
        onOk: () async {
          ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
          await Future.delayed(const Duration(seconds: 5));
          final result = await NotificationRepo.markNotificationAsRead(
              notification: widget.notification);
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

          if (result.error) {
            SnackbarManager.showErrorSnackbar(
                context: context,
                message: "Unable to mark notification as read");
            return;
          }

          SnackbarManager.showBasicSnackbar(
              context: context, message: "Marked as read");
          context.pop();
        },
        cancelLabel: !widget.notification.read ? null : 'Close',
        onCancel: () => context.pop());
  }

  Future<void> decline() async {
    // final response = await TransactionRepo.respondToTransaction(
    //   aprove: false,
    //   transaction: transaction, status: status)
  }
}
