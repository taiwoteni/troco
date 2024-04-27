import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/font-manager.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../providers/transaction-tab-index.dart';

class MenuToggle extends ConsumerWidget {
  const MenuToggle({super.key});

  @override
  Widget build(BuildContext context, ref) {
    bool firstSelected = ref.watch(menuToggleIndexProvider);
    final tabWidth =
        (MediaQuery.sizeOf(context).width - (SizeManager.extralarge)) / 4;
    return Container(
      width: tabWidth * 2 + 2,
      height: SizeManager.extralarge * 1.25,
      decoration: BoxDecoration(
          border: Border.all(color: ColorManager.accentColor, width: 1),
          borderRadius: BorderRadius.circular(SizeManager.extralarge),
          color: ColorManager.background),
      child: Stack(
        children: [
          Row(
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
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        ref.read(menuToggleIndexProvider.notifier).state = true,
                    borderRadius: BorderRadius.circular(SizeManager.extralarge),
                    splashColor: ColorManager.accentColor.withOpacity(0.4),
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                          color: firstSelected
                              ? Colors.white
                              : ColorManager.accentColor,
                          fontFamily: 'quicksand',
                          fontSize: FontSizeManager.regular,
                          fontWeight: FontWeightManager.bold),
                      textAlign: TextAlign.center,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child: const Text(
                        "Timeline",
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: InkWell(
                  onTap: () =>
                      ref.read(menuToggleIndexProvider.notifier).state = false,
                  borderRadius: BorderRadius.circular(SizeManager.extralarge),
                  splashColor: ColorManager.accentColor.withOpacity(0.4),
                  child: AnimatedDefaultTextStyle(
                    style: TextStyle(
                        color: !firstSelected
                            ? Colors.white
                            : ColorManager.accentColor,
                        fontFamily: 'quicksand',
                        fontSize: FontSizeManager.regular,
                        fontWeight: FontWeightManager.bold),
                    textAlign: TextAlign.center,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                    child: const Text(
                      "Detail",
                    ),
                  ),
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
