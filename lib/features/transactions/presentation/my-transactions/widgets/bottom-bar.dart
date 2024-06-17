import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/data/datasources/my-transaction-tab-items.dart';
import 'package:troco/features/transactions/presentation/my-transactions/providers/tab-provider.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final tabItemsList = tabItems();
    return Container(
        height: SizeManager.bottomBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(SizeManager.large * 1.5)),
            boxShadow: kElevationToShadow[3]),
        child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: ColorManager.accentColor,
            unselectedItemColor: ColorManager.secondary,
            elevation: 0,
            currentIndex: ref.watch(tabProvider),
            onTap: (index) => ref.watch(tabProvider.notifier).state = index,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeightManager.semibold,
                fontSize: FontSizeManager.small),
            unselectedLabelStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: FontSizeManager.small),
            items: tabItemsList.map((tabItem) {
              final bool isSelected =
                  tabItemsList.indexOf(tabItem) == ref.watch(tabProvider);
              return BottomNavigationBarItem(
                  icon: Align(
                    child: SvgIcon(
                      svgRes: tabItem.icon,
                      color: isSelected
                          ? ColorManager.accentColor
                          : ColorManager.secondary,
                      size: Size.square(isSelected ? 28 : 24),
                    ),
                  ),
                  label: tabItem.label);
            }).toList()));
  }
}
