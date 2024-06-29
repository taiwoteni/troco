import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class ToggleWidget extends StatefulWidget {
  final bool selected;
  final void Function() onChecked;
  final String label;

  const ToggleWidget(
      {super.key,
      required this.selected,
      required this.onChecked,
      required this.label});

  @override
  State<ToggleWidget> createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<ToggleWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.medium * 1.6),
      splashColor: ColorManager.accentColor.withOpacity(0.3),
      onTap: widget.onChecked,
      child: Container(
        constraints: const BoxConstraints(minWidth: 72.6),
        padding: const EdgeInsets.symmetric(
            vertical: SizeManager.regular * 1.25,
            horizontal: SizeManager.medium),
        decoration: BoxDecoration(
            color: widget.selected
                ? ColorManager.accentColor
                : ColorManager.tertiary,
            borderRadius: BorderRadius.circular(SizeManager.medium * 1.6)),
        alignment: Alignment.center,
        child: Text(
          widget.label.titleCase,
          maxLines: 1,
          style: TextStyle(
              fontFamily: "quicksand",
              color: widget.selected
                  ? ColorManager.primaryDark
                  : ColorManager.secondary,
              fontSize: FontSizeManager.regular * 0.8,
              fontWeight: FontWeightManager.semibold),
        ),
      ),
    );
  }
}
