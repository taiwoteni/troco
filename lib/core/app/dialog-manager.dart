import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/button/presentation/widget/button.dart';
import '../components/others/spacer.dart';
import 'color-manager.dart';
import 'font-manager.dart';
import 'size-manager.dart';

class DialogManager {
  final BuildContext context;

  const DialogManager({required this.context});

  Future<T?> showDialogContent<T extends Object?>(
      {Widget? icon,
      required final String title,
      required final String description,
      String? okLabel,
      String? cancelLabel,
      void Function()? onOk,
      void Function()? onCancel}) async {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return _dialogView(
            title: title,
            description: description,
            icon: icon,
            onOk: onOk,
            onCancel: onCancel,
            okLabel: okLabel,
            cancelLabel: cancelLabel);
      },
    );
  }

  Dialog _dialogView(
      {Widget? icon,
      required final String title,
      required final String description,
      String? okLabel,
      String? cancelLabel,
      void Function()? onOk,
      onCancel}) {
    return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SizeManager.extralarge,
                    vertical: SizeManager.medium),
                margin: const EdgeInsets.all(SizeManager.medium),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeManager.medium),
                    color: ColorManager.background),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mediumSpacer(),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: icon,
                      ),
                    ),
                    largeSpacer(),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: FontSizeManager.medium,
                          color: ColorManager.primary,
                          fontWeight: FontWeightManager.bold),
                    ),
                    mediumSpacer(),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'quicksand',
                          fontSize: FontSizeManager.regular * 0.9,
                          color: ColorManager.secondary,
                          fontWeight: FontWeightManager.medium),
                    ),
                    mediumSpacer(),
                    regularSpacer(),
                    Row(
                      children: [
                        if (cancelLabel != null)
                          Expanded(
                              child: CustomButton.small(
                            margin: okLabel != null
                                ? const EdgeInsets.only(
                                    right: SizeManager.regular)
                                : null,
                            label: cancelLabel,
                            color: Colors.red.shade600,
                            onPressed: onCancel,
                          )),
                        if (okLabel != null)
                          Expanded(
                              child: CustomButton.small(
                            label: okLabel,
                            color: ColorManager.accentColor,
                            onPressed: onOk,
                          )),
                      ],
                    ),
                    regularSpacer()
                  ],
                ),
              ),
              Positioned(
                height: IconSizeManager.medium,
                width: IconSizeManager.medium,
                top: 0,
                right: 0,
                child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        elevation: 0,
                        shape: const CircleBorder(),
                        side: BorderSide.none,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(0),
                        backgroundColor: ColorManager.accentColor),
                    child: Icon(
                      CupertinoIcons.clear_thick,
                      size: IconSizeManager.small,
                      color: ColorManager.primaryDark,
                    )),
              )
            ],
          ),
        ));
  }
}
