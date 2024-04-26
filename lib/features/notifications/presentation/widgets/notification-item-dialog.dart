import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/button/presentation/widget/button.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../../../core/app/color-manager.dart';

class NotificationDialog extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final void Function()? onOk, onCancel;

  const NotificationDialog(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      this.onOk,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              dialogWidget(),

              /// After the dialog view
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
          )),
    );
  }

  Widget dialogWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.extralarge, vertical: SizeManager.medium),
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
          buttons(),
          regularSpacer()
        ],
      ),
    );
  }

  Widget buttons() {
    return Row(
      children: [
        Expanded(
            child: CustomButton.small(
          label: "Reject",
          color: Colors.red.shade600,
        )),
        regularSpacer(),
        Expanded(
            child: CustomButton.small(
          label: "Accept",
          color: ColorManager.accentColor,
        )),
      ],
    );
  }
}
