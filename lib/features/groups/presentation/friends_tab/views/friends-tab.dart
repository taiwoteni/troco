import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/block/presentation/provider/blocked-users-provider.dart';
import 'package:troco/features/groups/presentation/friends_tab/providers/friends-provider.dart';
import 'package:troco/features/groups/presentation/friends_tab/widgets/friend-widget.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/search-provider.dart';

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
  late List<Client> friends, blockedUsers;

  @override
  void initState() {
    friends = AppStorage.getFriends();
    blockedUsers = AppStorage.getBlockedUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listenToFriendsChanges();
    listenToBlockedUserChanges();

    //Because of queries from the searchProvider

    final filteredFriends = ref.watch(collectionsSearchProvider).trim().isEmpty
        ? ref.watch(friendsListProvider).toSet().toList()
        : ref
            .watch(friendsListProvider)
            .where((element) => element.fullName.toLowerCase().contains(
                ref.watch(collectionsSearchProvider).trim().toLowerCase()))
            .toSet()
            .toList();

    return filteredFriends.isEmpty
        ? SliverFillRemaining(
            child: EmptyScreen(
              scale: ref.watch(collectionsSearchProvider).isEmpty ? 1.5 : 1,
              xIndex: ref.watch(collectionsSearchProvider).isEmpty ? 0 : 0.25,
              forward: true,
              lottie: AssetManager.lottieFile(
                  name: ref.watch(collectionsSearchProvider).isEmpty
                      ? "add-friends"
                      : "no-search-results"),
              label: ref.watch(collectionsSearchProvider).isEmpty
                  ? "Invite a client to Troco"
                  : "No Search result for '${ref.watch(collectionsSearchProvider)}'",
            ),
          )
        : SliverList.separated(
            itemCount: filteredFriends.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  FriendWidget(
                      key: ObjectKey(filteredFriends[index]),
                      client: filteredFriends[index]),
                  if (index == filteredFriends.length - 1) ...[
                    mediumSpacer(),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SizeManager.extralarge),
                        child: InfoText(
                            color: ColorManager.secondary,
                            alignment: Alignment.center,
                            fontSize: FontSizeManager.regular * 0.85,
                            text:
                                "Your Clients are your added contacts who are Troco users.")),
                    Gap(SizeManager.bottomBarHeight)
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

  Future<void> listenToFriendsChanges() async {
    ref.listen(friendsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(
            () => friends = data,
          );
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }

  Future<void> listenToBlockedUserChanges() async {
    ref.listen(blockedUsersStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(() {});
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
