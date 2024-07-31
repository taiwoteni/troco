import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/utils/category-converter.dart';
import 'package:troco/features/kyc/utils/enums.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final Client client;
  const ProfileHeader({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  final double profileIconSize = IconSizeManager.extralarge * 2;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getHomeUiOverlayStyle());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final appBarHeight = height * .425;

    return Container(
      width: double.maxFinite,
      height: appBarHeight,
      color: ColorManager.background,
      child: Stack(
        children: [
          firstLayer(appBarHeight: appBarHeight),
          Positioned(
              left: SizeManager.small,
              bottom: SizeManager.small,
              child: profileIcon())
        ],
      ),
    );
  }

  Widget firstLayer({required double appBarHeight}) {
    return SizedBox.fromSize(
      size: Size.fromHeight(appBarHeight),
      child: Column(
        children: [
          Expanded(flex: 6, child: backgroundLayer()),
          Expanded(flex: 3, child: mainDetails())
        ],
      ),
    );
  }

  Widget backgroundLayer() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AssetManager.imageFile(
                  name: "background-profile", ext: Extension.jpg)))),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Colors.black.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top +
                      SizeManager.regular,
                  left: SizeManager.medium),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgIcon(
                    size: const Size.square(IconSizeManager.medium),
                    color: Colors.white,
                    svgRes: AssetManager.svgFile(name: "back-chat")),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget mainDetails() {
    Client client = widget.client;
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
        left: profileIconSize + SizeManager.large,
        top: SizeManager.regular * 1.3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client.fullName,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.primary,
                fontFamily: 'lato',
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.large * 0.9),
          ),
          regularSpacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CategoryConverter.convertToString(
                        category: client.accountCategory)
                    .titleCase,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeightManager.semibold,
                    color: ColorManager.secondary.withOpacity(0.4),
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small),
              ),
              smallSpacer(),
              SvgIcon(
                  size: const Size.square(IconSizeManager.regular * 0.8),
                  color: ColorManager.secondary,
                  svgRes: AssetManager.svgFile(
                      name:
                          "${client.accountCategory.name.toLowerCase()}-icon"))
            ],
          ),
          regularSpacer(),
          Text(
            client.kycTier == VerificationTier.None
                ? "Not Verified"
                : "Tier ${KycConverter.convertToStringApi(tier: client.kycTier)} Troco Verified",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeightManager.semibold,
                color: ColorManager.accentColor,
                fontFamily: 'lato',
                fontSize: FontSizeManager.small),
          ),
        ],
      ),
    );
  }

  Widget profileIcon() {
    const double borderWidth = 5;
    return Container(
      width: profileIconSize + borderWidth,
      height: profileIconSize + borderWidth,
      decoration:
          BoxDecoration(color: ColorManager.background, shape: BoxShape.circle),
      padding: const EdgeInsets.all(borderWidth),
      child: Stack(
        children: [
          ProfileIcon(
            url: widget.client.profile,
            size: double.maxFinite,
          ),
          if (widget.client.kycTier != VerificationTier.None)
            Positioned(
                right: 0,
                bottom: 2,
                child: SizedBox.square(
                  dimension: IconSizeManager.medium * 1.2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        width: IconSizeManager.small,
                        height: IconSizeManager.small,
                      ),
                      SvgIcon(
                        svgRes: AssetManager.svgFile(name: "verification"),
                        color: ColorManager.accentColor,
                        size: const Size.square(IconSizeManager.medium * 1.2),
                      ),
                    ],
                  ),
                ))
        ],
      ),
    );
  }
}
