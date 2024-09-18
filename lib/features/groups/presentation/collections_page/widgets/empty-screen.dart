import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';

class EmptyScreen extends StatefulWidget {
  final String? lottie, label;
  final bool expanded, forward, loop, flip;
  final Color? lottieColor;
  final double scale, xIndex;
  const EmptyScreen(
      {super.key,
      this.scale = 1.0,
      this.expanded = false,
      this.xIndex = 0,
      this.forward = false,
      this.loop = true,
      this.lottieColor,
      this.lottie,
      this.flip = false,
      this.label});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.expanded
        ? Expanded(child: mainWidget())
        : Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            child: mainWidget());
  }

  Widget mainWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(
              (widget.forward ? -1 : 1) *
                  (widget.xIndex * IconSizeManager.extralarge * 2),
              1),
          child: Transform.scale(
            scale: widget.scale,
            child: Transform.flip(
              flipX: widget.flip,
              child: LottieWidget(
                  loop: widget.loop,
                  color: widget.lottieColor,
                  lottieRes:
                      widget.lottie ?? AssetManager.lottieFile(name: 'empty'),
                  size: const Size.square(IconSizeManager.extralarge * 2)),
            ),
          ),
        ),
        mediumSpacer(),
        Text(
          widget.label ?? "Nothing Here",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontWeight: FontWeightManager.medium,
              fontSize: FontSizeManager.large * 0.7),
        ),
      ],
    );
  }
}
