import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';

class EmptyScreen extends StatefulWidget {
  final String? lottie, label;
  final bool expanded;
  final double scale;
  const EmptyScreen(
      {super.key, this.scale = 1.0, this.expanded = false, this.lottie, this.label});

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
      children: [
        Transform.scale(
          scale: widget.scale,
          child: LottieWidget(
              lottieRes: widget.lottie ?? AssetManager.lottieFile(name: 'empty'),
              size: const Size.square(IconSizeManager.extralarge * 2)),
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
