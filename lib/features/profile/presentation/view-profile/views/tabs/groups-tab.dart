import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/groups-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/groups-in-common-widget.dart';

import '../../../../../../core/app/color-manager.dart';
import '../../../../../../core/app/font-manager.dart';
import '../../../../../../core/app/size-manager.dart';
import '../../../../../groups/presentation/collections_page/widgets/empty-screen.dart';

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends ConsumerState<GroupsTab> {
  @override
  Widget build(BuildContext context) {
    if (ref.watch(groupsProfileProvider).isEmpty) {
      return SliverFillRemaining(
        child: EmptyScreen(
          label:
              "${ref.watch(userProfileProvider)!.firstName} doesn't have any group.",
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
          groupsList(),
        ]));
  }

  Widget title() {
    return Text(
      "Orders",
      style: TextStyle(
          fontSize: FontSizeManager.large * 1.05,
          fontWeight: FontWeightManager.extrabold,
          fontFamily: 'quicksand',
          color: ColorManager.primary),
    );
  }

  Widget groupsList() {
    return Column(
      children: List.generate(
        ref.watch(groupsProfileProvider).length,
        (index) {
          return GroupsInCommonWidget(
            key: ObjectKey(ref.read(groupsProfileProvider)[index]),
            client: ref.read(userProfileProvider)!,
            group: ref.read(groupsProfileProvider)[index],
            inCommon: false,
          );
        },
      ),
    );
  }
}
