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
      UniqueKey? okKey,
      cancelKey,
      void Function()? onOk,
      void Function()? onCancel}) async {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return DialogView(
            title: title,
            description: description,
            icon: icon,
            onOk: onOk,
            okKey: okKey,
            cancelKey: cancelKey,
            onCancel: onCancel,
            okLabel: okLabel,
            cancelLabel: cancelLabel);
      },
    );
  }
}

class DialogView extends StatefulWidget {
  final Widget? icon;
  final String title, description;
  final String? okLabel, cancelLabel;
  final UniqueKey? okKey, cancelKey;
  final void Function()? onOk, onCancel;

  const DialogView(
      {super.key,
      this.icon,
      required this.title,
      required this.description,
      this.okLabel,
      this.cancelLabel,
      this.onOk,
      this.okKey,
      this.cancelKey,
      this.onCancel});

  @override
  State<DialogView> createState() => _DialogViewState();
}

class _DialogViewState extends State<DialogView> {
  late UniqueKey okKey, cancelKey;

  @override
  void initState() {
    okKey = widget.okKey ?? UniqueKey();
    cancelKey = widget.cancelKey ?? UniqueKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: widget.icon,
                      ),
                    ),
                    largeSpacer(),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: FontSizeManager.medium,
                          color: ColorManager.primary,
                          fontWeight: FontWeightManager.bold),
                    ),
                    mediumSpacer(),
                    Text(
                      widget.description,
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
                        if (widget.cancelLabel != null)
                          Expanded(
                              child: CustomButton.small(
                            margin: widget.okLabel != null
                                ? const EdgeInsets.only(
                                    right: SizeManager.regular)
                                : null,
                            buttonKey: cancelKey,
                            usesProvider: true,
                            label: widget.cancelLabel!,
                            color: Colors.red.shade600,
                            onPressed: widget.onCancel,
                          )),
                        if (widget.okLabel != null)
                          Expanded(
                              child: CustomButton.small(
                            label: widget.okLabel!,
                            buttonKey: okKey,
                            usesProvider: true,
                            color: ColorManager.accentColor,
                            onPressed: widget.onOk,
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
