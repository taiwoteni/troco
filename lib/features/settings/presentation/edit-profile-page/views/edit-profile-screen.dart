import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/images/badge-icon.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            largeSpacer(),
            profileWidget(),
            
          ],
        ),
      ),
    );
  }

  Widget profileWidget(){
    return Container(
      width: IconSizeManager.extralarge * 2,
      height: IconSizeManager.extralarge * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle
      ),
      child: ProfileIcon(
        size: double.maxFinite,
        url: ClientProvider.readOnlyClient!.profile,
        badge: Positioned(
          bottom: 0,
          right: 0,
          child: BadgeIcon(
            size: IconSizeManager.medium,
            iconType: BadgeIconType.icon,
            iconData: Icons.edit_rounded,)),
        ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}