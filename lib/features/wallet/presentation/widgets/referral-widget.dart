import 'package:flutter/material.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/utils/enums.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/profile-icon.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';

class ReferralWidget extends StatefulWidget {
  final Referral referral;
  final bool enabled, pushReplace;
  const ReferralWidget(
      {super.key,
      required this.referral,
      this.enabled = true,
      this.pushReplace = false});

  @override
  State<ReferralWidget> createState() => _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
  late Referral referral;

  @override
  void initState() {
    referral = widget.referral;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.only(
        top: SizeManager.small,
        bottom: SizeManager.small,
      ),
      horizontalTitleGap: SizeManager.medium * 0.8,
      onTap: () {
        if (!widget.enabled) {
          return;
        }

        final json = {
          "firstName": referral.fullName.split(' ')[0],
          "lastName": referral.fullName.split(' ').last,
          "userImage": referral.profile,
          "_id": referral.id,
          "email": referral.email,
        };
        final client = Client.fromJson(json: json);

        if (widget.pushReplace) {
          context.pushReplacementNamed(
              routeName: Routes.viewProfileRoute, arguments: client);
          return;
        }
        context.pushNamed(
            routeName: Routes.viewProfileRoute, arguments: client);
      },
      leading: profileIcon(),
      title: Row(
        children: [
          Text(
            referral.fullName,
          ),
          // if (referral.user.verified) ...[
          //   smallSpacer(),
          //   SvgIcon(
          //     svgRes: AssetManager.svgFile(name: "verification"),
          //     color: ColorManager.accentColor,
          //     size: const Size.square(IconSizeManager.small),
          //   )
          // ]
        ],
      ),
      titleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.primary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium * 1.1,
          fontWeight: FontWeightManager.semibold),
      subtitle: Text(referral.referralStatus.name),
      subtitleTextStyle: TextStyle(
          color: referral.referralStatus == ReferralStatus.Pending
              ? Colors.red
              : ColorManager.accentColor,
          fontFamily: 'Quicksand',
          fontSize: FontSizeManager.regular * 0.9,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget profileIcon() {
    return SizedBox.square(
      dimension: 53,
      child: ProfileIcon(
        size: 53,
        url: referral.profile,
      ),
    );
  }
}
