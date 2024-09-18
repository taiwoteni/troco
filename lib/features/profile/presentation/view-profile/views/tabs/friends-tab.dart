import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/groups/presentation/friends_tab/widgets/friend-widget.dart';
import 'package:troco/features/notifications/presentation/widgets/notification-menu-button.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/friends-provider.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  ConsumerState createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends ConsumerState<FriendsTab> {
  bool listMutual = false;
  @override
  Widget build(BuildContext context) {
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
          friendsList()
        ]));
  }

  Widget title() {
    return Text(
      "Friends",
      style: TextStyle(
          fontSize: FontSizeManager.large * 1.05,
          fontWeight: FontWeightManager.extrabold,
          fontFamily: 'quicksand',
          color: ColorManager.primary),
    );
  }

  Widget titleButtons() {
    return Row(
      children: [
        ToggleWidget(
            selected: !listMutual,
            onChecked: () => setState(() => listMutual = false),
            label: "All"),
        mediumSpacer(),
        ToggleWidget(
            selected: listMutual,
            onChecked: () => setState(() => listMutual = true),
            label: "Mutual"),
      ],
    );
  }

  Widget friendsList() {
    log(ref.watch(friendsProfileProvider).length.toString());
    return Column(
      children: List.generate(
        ref.watch(friendsProfileProvider).length,
        (index) {
          return FriendWidget(
            key: ObjectKey(ref.read(friendsProfileProvider)[index]),
            client: ref.read(friendsProfileProvider)[index],
            applyHorizontalPadding: false,
          );
        },
      ),
    );
  }
}
