// ignore_for_file: must_be_immutable

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/kyc/utils/enums.dart';

import '../../../../core/app/asset-manager.dart';

class VerificationRequirementWidget extends ConsumerStatefulWidget {
  VerificationRequirementWidget(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      this.process,
      this.size = IconSizeManager.extralarge,
      this.met = false,
      this.onTap});

  final void Function()? onTap;
  final String title;
  final String description;
  final double size;
  VerificationProcess? process;
  final Widget icon;
  bool met;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerificationRequirementWidgetState();
}

class _VerificationRequirementWidgetState
    extends ConsumerState<VerificationRequirementWidget> {
  final key = GlobalKey();
  double height = 123.0;
  double minPerfectScreenWidth = 346.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.met && widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: DottedBorder(
        color: ColorManager.accentColor,
        strokeWidth: 2,
        borderType: BorderType.RRect,
        dashPattern: const [5, 6],
        radius: const Radius.circular(SizeManager.regular),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.medium, horizontal: SizeManager.medium),
          child: Row(
            key: key,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              texts(),
              widget.met
                  ? verified()
                  : widget.process == null
                      ? SizedBox.square(
                          dimension: widget.size,
                          child:
                              FittedBox(fit: BoxFit.cover, child: widget.icon))
                      : animation(process: widget.process!),
            ],
          ),
        ),
      ),
    );
  }

  Widget verified() {
    return Transform.scale(
      scale: 1.1,
      child: LottieWidget(
          lottieRes: AssetManager.lottieFile(name: "verified"),
          fit: BoxFit.cover,
          loop: false,
          size: Size.square(widget.size)),
    );
  }

  Widget animation({required VerificationProcess process}) {
    return Transform.scale(
      scale: [VerificationProcess.Processing, VerificationProcess.Uploading]
              .contains(process)
          ? 2
          : 1.25,
      child: LottieWidget(
        lottieRes: AssetManager.lottieFile(
            name: process == VerificationProcess.Processing
                ? "kyc-scanning"
                : process == VerificationProcess.Uploading
                    ? "kyc-uploading"
                    : "kyc-document"),
        size: Size.square(widget.size),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget title() {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth >= minPerfectScreenWidth
        ? 1
        : screenWidth / minPerfectScreenWidth * 0.9);
    return Text(
      widget.title,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.medium * scale,
          fontWeight: FontWeightManager.semibold),
    );
  }

  Widget description() {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth >= minPerfectScreenWidth
        ? 1
        : screenWidth / minPerfectScreenWidth * 0.9);
    return Text(
      widget.description,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 0.9 * scale,
          fontWeight: FontWeightManager.regular),
    );
  }

  Widget texts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(),
        regularSpacer(),
        description(),
      ],
    );
  }
}
