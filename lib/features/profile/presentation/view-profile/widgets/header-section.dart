import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/core/extensions/text-extensions.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/profile-icon.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../auth/domain/entities/client.dart';
import '../../../../auth/utils/category-converter.dart';
import '../../../../transactions/utils/enums.dart';

class HeaderSection extends ConsumerStatefulWidget {
  const HeaderSection({super.key});

  @override
  ConsumerState<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends ConsumerState<HeaderSection> {
  late Client client;
  @override
  Widget build(BuildContext context) {
    client = ref.watch(userProfileProvider)!;
    return SliverAppBar(
      systemOverlayStyle: ThemeManager.getWalletUiOverlayStyle(),
      expandedHeight: 267 + MediaQuery.viewPaddingOf(context).top,
      backgroundColor: ColorManager.background,
      forceElevated: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          color: ColorManager.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(MediaQuery.viewPaddingOf(context).top),
              appBar(context: context),
              mediumSpacer(),
              profileIcon(),
              regularSpacer(),
              smallSpacer(),
              nameText(),
              regularSpacer(),
              accountType(),
              regularSpacer(),
              lastSeen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar({required final BuildContext context}) {
    return Container(
      width: double.maxFinite,
      height: 72,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.maxFinite,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: () => context.pop(),
                iconSize: IconSizeManager.regular * 1.25,
                icon: SvgIcon(
                    size: const Size.square(IconSizeManager.regular * 1.25),
                    color: Colors.black,
                    svgRes: AssetManager.svgFile(name: "back-chat")),
              ),
            ),
            Positioned(
                child: Text(
              "${client.firstName}'s Profile",
              style: TextStyle(
                  color: ColorManager.primary,
                  fontWeight: FontWeightManager.bold,
                  fontSize: FontSizeManager.regular),
            ).quicksand()),
          ],
        ),
      ),
    );
  }

  Widget profileIcon() {
    const double profileIconSize = IconSizeManager.extralarge * 1.2;
    return Container(
      width: profileIconSize,
      height: profileIconSize,
      decoration:
          BoxDecoration(color: ColorManager.background, shape: BoxShape.circle),
      child: Stack(
        children: [
          ProfileIcon(
            url: client.profile,
            size: double.maxFinite,
          ),
          Positioned(
              bottom: 3,
              right: 2,
              child: Container(
                width: profileIconSize * .22,
                height: profileIconSize * .22,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: ColorManager.background,
                        width: 3,
                        strokeAlign: BorderSide.strokeAlignOutside),
                    color:
                        client.online ? ColorManager.accentColor : Colors.red),
              ))
        ],
      ),
    );
  }

  Widget nameText() {
    final verified = client.verified;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(client.fullName,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontSize: FontSizeManager.regular * 1.1,
                    fontWeight: FontWeightManager.semibold))
            .lato(),
        if (verified) ...[
          smallSpacer(),
          SvgIcon(
            svgRes: AssetManager.svgFile(name: "verification"),
            fit: BoxFit.cover,
            color: ColorManager.accentColor,
            size: const Size.square(IconSizeManager.regular * 0.8),
          )
        ]
      ],
    );
  }

  Color getColor() {
    switch (client.accountCategory) {
      case Category.Personal:
        return Colors.amber;
      case Category.Business:
        return Colors.blue;
      case Category.Company:
        return Colors.purple;
      case Category.Merchant:
        return Colors.deepOrangeAccent;
    }
  }

  Widget accountType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          CategoryConverter.convertToString(category: client.accountCategory)
              .titleCase,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeightManager.semibold,
              color: getColor(),
              fontFamily: 'lato',
              fontSize: FontSizeManager.small),
        ),
        smallSpacer(),
        SvgIcon(
            size: const Size.square(IconSizeManager.regular * 0.6),
            color: getColor(),
            svgRes: AssetManager.svgFile(
                name: "${client.accountCategory.name.toLowerCase()}-icon"))
      ],
    );
  }

  Widget lastSeen() {
    String lastSeenText = "yesterday";
    final now = DateTime.now();
    final lastSeen = client.lastSeen;
    if (now.year == lastSeen.year) {
      if (now.month == lastSeen.month) {
        if (now.day == lastSeen.day) {
          lastSeenText = DateFormat('hh:mm a').format(lastSeen);
        } else if (now.day == lastSeen.day - 1) {
          lastSeenText = "yesterday";
        }
      } else {
        lastSeenText = DateFormat('EEE, MMM d').format(lastSeen);
      }
    } else {
      lastSeenText = DateFormat('EEE, MMM d yyyy').format(lastSeen);
    }

    return Text(client.online ? "Online" : "Last seen $lastSeenText",
            style: TextStyle(
                color: ColorManager.secondary,
                fontSize: FontSizeManager.regular * 0.9,
                fontWeight: FontWeightManager.medium))
        .quicksand();
  }
}
