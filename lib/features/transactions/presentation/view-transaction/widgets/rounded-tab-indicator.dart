import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class RoundedTabIndicator extends StatefulWidget {
  final bool firstSelected;
  const RoundedTabIndicator({super.key, required this.firstSelected});

  @override
  State<RoundedTabIndicator> createState() => _RoundedTabIndicatorState();
}

class _RoundedTabIndicatorState extends State<RoundedTabIndicator> {
  @override
  Widget build(BuildContext context) {
    final tabWidth =
        (MediaQuery.sizeOf(context).width - SizeManager.medium * 2) / 2;
    return Container(
      width: double.maxFinite,
      height: SizeManager.small * 1.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.extralarge),
          color: ColorManager.secondary.withOpacity(0.09)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            width: widget.firstSelected ? 0 : tabWidth,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(SizeManager.extralarge),
            ),
          ),
          Container(
            width: tabWidth,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: ColorManager.accentColor,
              borderRadius: BorderRadius.circular(SizeManager.extralarge),
            ),
          ),
        ],
      ),
    );
  }
}
