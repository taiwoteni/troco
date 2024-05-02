import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeManager.bottomBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.large * 1.5)),
          boxShadow: kElevationToShadow[3]),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SizeManager.large * 1.5)),
        child: BottomNavigationBar(
            onTap: (value) => ref.watch(homeProvider.notifier).state = value,
            backgroundColor: Colors.transparent,
            selectedItemColor: ColorManager.accentColor,
            unselectedItemColor: ColorManager.secondary,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: ref.watch(homeProvider),
            selectedLabelStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeightManager.semibold,
                fontSize: FontSizeManager.small),
            unselectedLabelStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: FontSizeManager.small),
            items: homeItems.map((homeItem) {
              final bool isSelected =
                  homeItems.indexOf(homeItem) == ref.watch(homeProvider);
              return BottomNavigationBarItem(
                  icon: Align(
                    child: SvgIcon(
                      svgRes: homeItem.icon,
                      color: isSelected ? ColorManager.accentColor : null,
                      size: Size.square(isSelected ? 28 : 24),
                    ),
                  ),
                  label: homeItem.label);
            }).toList()),
      ),
    );
  }
}
