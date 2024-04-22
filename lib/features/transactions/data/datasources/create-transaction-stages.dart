import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/transactions/presentation/providers/create-transaction-provider.dart';

List<Widget> createTransactionStages({required WidgetRef ref}) {
  int currentIndex = ref.watch(createTransactionProgressProvider);
  const Color disabledColor = Color.fromARGB(255, 223, 218, 218);
  final TextStyle textStyle = TextStyle(
      fontFamily: "Lato",
      color: ColorManager.primary,
      fontSize: FontSizeManager.regular * 0.81,
      fontWeight: FontWeightManager.semibold);
  return [
    GestureDetector(
      onTap: () {
        if (currentIndex > 0) {
          ref
              .read(createTransactionPageController.notifier)
              .state
              .animateToPage(0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.ease);
        }
      },
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        isFirst: true,
        endChild: Padding(
          padding: const EdgeInsets.only(top: SizeManager.medium),
          child: Text(
            "Category",
            style: textStyle,
          ),
        ),
        indicatorStyle: IndicatorStyle(
            width: IconSizeManager.medium * 1.1,
            height: IconSizeManager.medium * 1.1,
            
            iconStyle: IconStyle(
                fontSize: IconSizeManager.regular * 0.9,
                iconData:
                    currentIndex > 0 ? Icons.check_rounded : Icons.edit_rounded,
                color: ColorManager.primaryDark),
            color:
                currentIndex >= 0 ? ColorManager.accentColor : disabledColor),
        afterLineStyle: LineStyle(
          color: ColorManager.accentColor,
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        if (currentIndex >= 1) {
          ref
              .read(createTransactionPageController.notifier)
              .state
              .animateToPage(1,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.ease);
        }
      },
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        endChild: Padding(
          padding: const EdgeInsets.only(top: SizeManager.medium),
          child: Text(
            "Description",
            style: textStyle,
          ),
        ),
        beforeLineStyle: LineStyle(
          color: currentIndex > 0 ? ColorManager.accentColor : disabledColor,
        ),
        afterLineStyle: LineStyle(
          color: currentIndex >= 1 ? ColorManager.accentColor : disabledColor,
        ),
        indicatorStyle: IndicatorStyle(
            width: IconSizeManager.medium * 1.1,
            height: IconSizeManager.medium * 1.1,
            iconStyle: IconStyle(
                fontSize: IconSizeManager.regular * 0.9,
                iconData:
                    currentIndex > 1 ? Icons.check_rounded : Icons.edit_rounded,
                color: ColorManager.primaryDark),
            color:
                currentIndex >= 1 ? ColorManager.accentColor : disabledColor),
      ),
    ),
    GestureDetector(
      onTap: () {
        if (currentIndex >= 2) {
          ref
              .read(createTransactionPageController.notifier)
              .state
              .animateToPage(2,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.ease);
        }
      },
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        endChild: Padding(
          padding: const EdgeInsets.only(top: SizeManager.medium),
          child: Text(
            "Pricing",
            style: textStyle,
          ),
        ),
        beforeLineStyle: LineStyle(
          color: currentIndex > 1 ? ColorManager.accentColor : disabledColor,
        ),
        afterLineStyle: LineStyle(
          color: currentIndex >= 2 ? ColorManager.accentColor : disabledColor,
        ),
        indicatorStyle: IndicatorStyle(
            width: IconSizeManager.medium * 1.1,
            height: IconSizeManager.medium * 1.1,
            iconStyle: IconStyle(
                fontSize: IconSizeManager.regular * 0.9,
                iconData:
                    currentIndex > 2 ? Icons.check_rounded : Icons.edit_rounded,
                color: ColorManager.primaryDark),
            color:
                currentIndex >= 2 ? ColorManager.accentColor : disabledColor),
      ),
    ),
    GestureDetector(
      onTap: () {
        if (currentIndex >= 3) {
          ref
              .read(createTransactionPageController.notifier)
              .state
              .animateToPage(3,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.ease);
        }
      },
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        endChild: Padding(
          padding: const EdgeInsets.only(top: SizeManager.medium),
          child: Text(
            "Preview",
            style: textStyle,
          ),
        ),
        isLast: true,
        beforeLineStyle: LineStyle(
          color: currentIndex > 2 ? ColorManager.accentColor : disabledColor,
        ),
        indicatorStyle: IndicatorStyle(
            width: IconSizeManager.medium * 1.1,
            height: IconSizeManager.medium * 1.1,
            iconStyle: IconStyle(
                fontSize: IconSizeManager.regular * 0.9,
                iconData:
                    currentIndex > 3 ? Icons.check_rounded : Icons.edit_rounded,
                color: ColorManager.primaryDark),
            color:
                currentIndex >= 3 ? ColorManager.accentColor : disabledColor),
      ),
    )
  ];
}
