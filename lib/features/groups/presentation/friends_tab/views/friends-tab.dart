import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/groups/presentation/friends_tab/widgets/friend-widget.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../auth/domain/entities/client.dart';
import '../../collections_page/widgets/empty-screen.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  late List<Client> friends;

  @override
  void initState() {
    friends = AppStorage.getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return friends.isEmpty
        ? SliverFillRemaining(
            child: EmptyScreen(
              scale: 1.5,
              lottie: AssetManager.lottieFile(name: "add-friends"),
              label: "Invite a friend to Troco",
            ),
          )
        : SliverList.separated(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  FriendWidget(
                      key: ObjectKey(friends[index]), client: friends[index]),
                  if (index == friends.length - 1) ...[
                    mediumSpacer(),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SizeManager.extralarge),
                        child: InfoText(
                            color: ColorManager.secondary,
                            alignment: Alignment.center,
                            fontSize: FontSizeManager.regular * 0.85,
                            text:
                                "Your Friends are your contacts who are Troco users.")),
                    const Gap(SizeManager.bottomBarHeight)
                  ],
                ],
              );
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
          );
  }
}
