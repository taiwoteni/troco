// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';

class SelectPaymentMethodWidget extends StatefulWidget {
  bool selected;
  final bool moveLeft;
  final void Function() onChecked;
  final String label, lottie;

  SelectPaymentMethodWidget(
      {super.key,
      required this.selected,
      required this.onChecked,
      this.moveLeft = false,
      required this.label,
      required this.lottie});

  @override
  State<SelectPaymentMethodWidget> createState() =>
      _SelectPaymentMethodWidgetState();
}

class _SelectPaymentMethodWidgetState extends State<SelectPaymentMethodWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeManager.regular),
        splashColor: ColorManager.accentColor.withOpacity(0.1),
        onTap: () {
          widget.onChecked();
        },
        child: Container(
          width: double.maxFinite,
          height: 95,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset:
                    widget.moveLeft ? const Offset(-8, 0) : const Offset(0, 0),
                child: Transform.scale(
                  scale: 1.2,
                  child: LottieWidget(
                      lottieRes: widget.lottie,
                      size: const Size.square(IconSizeManager.medium)),
                ),
              ),
              smallSpacer(),
              Text(
                widget.label,
                style: TextStyle(
                    fontFamily: "quicksand",
                    color: ColorManager.primary,
                    fontSize: FontSizeManager.small,
                    fontWeight: FontWeightManager.semibold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
