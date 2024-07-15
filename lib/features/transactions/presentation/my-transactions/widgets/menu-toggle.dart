import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/features/transactions/presentation/my-transactions/providers/statistics-mode-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';

final _bgColor = ColorManager.secondary.withOpacity(0.07);

class MenuToggle extends ConsumerWidget {
  const MenuToggle({super.key});

  @override
  Widget build(BuildContext context, ref) {
    bool firstSelected =
        ref.watch(statisticsMode) == TransactionPurpose.Selling;
    final tabWidth =
        (MediaQuery.sizeOf(context).width - (SizeManager.extralarge)) / 3.8;
    return Container(
      width: tabWidth * 2 + 2,
      height: SizeManager.extralarge * 1.3,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.extralarge),
          color: _bgColor),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
                width: tabWidth,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  color: firstSelected
                      ? ColorManager.accentColor
                      : Colors.redAccent,
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
                    onTap: () => ref.read(statisticsMode.notifier).state =
                        TransactionPurpose.Selling,
                    borderRadius: BorderRadius.circular(SizeManager.extralarge),
                    splashColor: ColorManager.accentColor.withOpacity(0.4),
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                          color: !firstSelected
                              ? ColorManager.secondary
                              : Colors.white,
                          fontFamily: 'quicksand',
                          fontSize: FontSizeManager.regular,
                          fontWeight: FontWeightManager.semibold),
                      textAlign: TextAlign.center,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child: const Text(
                        "Selling",
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: InkWell(
                  onTap: () => ref.read(statisticsMode.notifier).state =
                      TransactionPurpose.Buying,
                  borderRadius: BorderRadius.circular(SizeManager.extralarge),
                  splashColor: ColorManager.accentColor.withOpacity(0.4),
                  child: AnimatedDefaultTextStyle(
                    style: TextStyle(
                        color: firstSelected
                            ? ColorManager.secondary
                            : Colors.white,
                        fontFamily: 'quicksand',
                        fontSize: FontSizeManager.regular,
                        fontWeight: FontWeightManager.semibold),
                    textAlign: TextAlign.center,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                    child: const Text(
                      "Buying",
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
