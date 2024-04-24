import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';

class CustomTabWidget extends ConsumerWidget {
  final bool isTransation;
  final bool isFirst;
  final String description;
  const CustomTabWidget(
      {super.key,
      required this.isTransation,
      this.isFirst = false,
      required this.description});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabWidth =
        (MediaQuery.sizeOf(context).width - SizeManager.medium * 2) / 2;
    return InkWell(
      borderRadius: BorderRadius.only(
          topLeft: isTransation
              ? const Radius.circular(SizeManager.regular)
              : Radius.zero,
          topRight: !isTransation
              ? const Radius.circular(SizeManager.regular)
              : Radius.zero,
          bottomLeft: isTransation
              ? const Radius.circular(SizeManager.regular)
              : Radius.zero,
          bottomRight: !isTransation
              ? const Radius.circular(SizeManager.regular)
              : Radius.zero),
      splashColor: ColorManager.secondary.withOpacity(0.002),
      onTap: () {
        ref.read(tabIndexProvider.notifier).state = isFirst ? 0 : 1;
        if (isFirst) {
          ref.read(tabControllerProvider.notifier).state.nextPage(
              duration: const Duration(milliseconds: 600), curve: Curves.ease);
        } else {
          ref.read(tabControllerProvider.notifier).state.previousPage(
              duration: const Duration(milliseconds: 600), curve: Curves.ease);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
        width: tabWidth,
        child: Row(
          children: [
            circleIcon(),
            regularSpacer(),
            smallSpacer(),
            nameWidget(),
          ],
        ),
      ),
    );
  }

  Widget circleIcon() {
    final Color color = ColorManager.accentColor;
    return Container(
      width: IconSizeManager.large * 0.85,
      height: IconSizeManager.large * 0.85,
      margin: const EdgeInsets.all(SizeManager.small),
      alignment: Alignment.center,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
      child: SvgIcon(
        svgRes: AssetManager.svgFile(name: "delivery"),
        size: const Size.square(IconSizeManager.small * 1.3),
        color: color,
      ),
    );
  }

  Widget nameWidget() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTransation ? "Details" : "Progress",
            style: TextStyle(
                color: ColorManager.primary.withOpacity(0.8),
                height: 0.9,
                fontFamily: 'lato',
                fontSize: FontSizeManager.medium * 0.95,
                fontWeight: FontWeightManager.extrabold),
          ),
          const Gap(SizeManager.small / 2),
          Text(
            description,
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'quicksand',
                fontSize: FontSizeManager.small * 0.8,
                fontWeight: FontWeightManager.extrabold),
          ),
        ],
      ),
    );
  }
}
