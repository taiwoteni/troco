// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';

import '../providers/transaction-tab-index.dart';

class RoundedTabIndicator extends ConsumerWidget {
  const RoundedTabIndicator({super.key});

  @override
  Widget build(BuildContext context, ref) {
    bool firstSelected = ref.watch(tabIndexProvider) == 0;
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
            width: firstSelected ? 0 : tabWidth,
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
