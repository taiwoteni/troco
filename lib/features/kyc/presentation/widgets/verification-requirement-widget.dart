// ignore_for_file: must_be_immutable

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/others/spacer.dart';

class VerificationRequirementWidget extends ConsumerStatefulWidget {
  VerificationRequirementWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.met = false,
  });

  final String title;
  final String description;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
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
            widget.icon,
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      widget.title,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.semibold),
    );
  }

  Widget description() {
    return Text(
      widget.description,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 0.9,
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
