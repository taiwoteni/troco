import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

class SelectTransactionTypeWidget extends StatefulWidget {
  final bool selected;
  final void Function() onChecked;
  final String label, description;

  const SelectTransactionTypeWidget(
      {super.key,
      required this.selected,
      required this.onChecked,
      required this.label,
      required this.description});

  @override
  State<SelectTransactionTypeWidget> createState() =>
      _SelectTransactionTypeWidgetState();
}

class _SelectTransactionTypeWidgetState
    extends State<SelectTransactionTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {
        widget.onChecked();
      },
      child: Container(
        width: double.maxFinite,
        height: 85,
        decoration: BoxDecoration(
            color: widget.selected
                ? ColorManager.accentColor.withOpacity(0.05)
                : ColorManager.background,
            border: Border.all(
                color: widget.selected
                    ? ColorManager.accentColor
                    : ColorManager.secondary.withOpacity(0.09),
                width: 2),
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: Row(
          children: [
            regularSpacer(),
            Radio(
                value: widget.selected,
                groupValue: true,
                fillColor: MaterialStatePropertyAll(ColorManager.accentColor),
                activeColor: ColorManager.accentColor,
                toggleable: false,
                onChanged: null),
            mediumSpacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.medium * 0.9,
                      fontWeight: FontWeightManager.semibold),
                ),
                smallSpacer(),
                Text(
                  widget.description,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.regular * 0.72,
                      fontWeight: FontWeightManager.semibold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
