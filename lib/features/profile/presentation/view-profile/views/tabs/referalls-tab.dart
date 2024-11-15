import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/referrals-provider.dart';
import 'package:troco/features/wallet/presentation/widgets/referral-widget.dart';

import '../../../../../../core/app/color-manager.dart';
import '../../../../../../core/app/font-manager.dart';
import '../../../../../../core/app/size-manager.dart';
import '../../../../../../core/components/others/spacer.dart';
import '../../../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../../../../notifications/presentation/widgets/notification-menu-button.dart';
import '../../providers/client-provider.dart';

class ReferralsTab extends ConsumerStatefulWidget {
  const ReferralsTab({super.key});

  @override
  ConsumerState createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends ConsumerState<ReferralsTab> {
  @override
  Widget build(BuildContext context) {
    if (ref.watch(referralsProfileProvider).isEmpty) {
      return SliverFillRemaining(
        child: EmptyScreen(
          label:
              "${ref.watch(userProfileProvider)!.firstName} doesn't have any referrals.",
        ),
      );
    }
    return SliverPadding(
        padding: const EdgeInsets.only(
          top: SizeManager.large,
          left: SizeManager.large,
          right: SizeManager.large,
        ),
        sliver: SliverList.list(children: [
          title(),
          mediumSpacer(),
          // titleButtons(),
          // regularSpacer(),
          referralsList()
        ]));
  }

  Widget title() {
    return Text(
      "Referrals",
      style: TextStyle(
          fontSize: FontSizeManager.large * 1.05,
          fontWeight: FontWeightManager.extrabold,
          fontFamily: 'quicksand',
          color: ColorManager.primary),
    );
  }

  // Widget titleButtons() {
  //   return Row(
  //     children: [
  //       ToggleWidget(
  //           selected: !listMutual,
  //           onChecked: () => setState(() => listMutual = false),
  //           label: "All"),
  //       mediumSpacer(),
  //       ToggleWidget(
  //           selected: listMutual,
  //           onChecked: () => setState(() => listMutual = true),
  //           label: "Mutual"),
  //     ],
  //   );
  // }

  Widget referralsList() {
    return Column(
      children: List.generate(
        ref.watch(referralsProfileProvider).length,
        (index) {
          return ReferralWidget(
              key: ObjectKey(ref.read(referralsProfileProvider)[index]),
              referral: ref.read(referralsProfileProvider)[index]);
        },
      ),
    );
  }
}
