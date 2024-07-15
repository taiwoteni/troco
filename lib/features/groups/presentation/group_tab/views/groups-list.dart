
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../chat/domain/entities/chat.dart';
import '../../../domain/entities/group.dart';
import '../../collections_page/widgets/empty-screen.dart';
import '../providers/search-provider.dart';
import '../widgets/group-widget.dart';

class GroupList extends ConsumerStatefulWidget {
  final List<Group> groups;
  const GroupList({super.key, required this.groups});

  @override
  ConsumerState<GroupList> createState() => _GroupListState();
}

class _GroupListState extends ConsumerState<GroupList> {
  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupSearchProvider).trim().isEmpty
        ? widget.groups
        : widget.groups
            .where(
              (element) => element.groupName.toLowerCase().trim().contains(
                  ref.watch(groupSearchProvider).trim().toLowerCase()),
            )
            .toList();

    groups.sort((groupA, groupB) {
      List<Chat> chatsA = ((groupA.toJson()["messages"] ?? []) as List)
          .map((e) => Chat.fromJson(json: e))
          .toList();
      List<Chat> chatsB = ((groupB.toJson()["messages"] ?? []) as List)
          .map((e) => Chat.fromJson(json: e))
          .toList();

      bool chatsGroupAEmpty = chatsA.isEmpty;
      bool chatsGroupBEmpty = chatsB.isEmpty;

      DateTime timeA = chatsGroupAEmpty ? groupA.createdTime : chatsA.last.time;
      DateTime timeB = chatsGroupBEmpty ? groupB.createdTime : chatsB.last.time;

      return timeB.compareTo(timeA);
    });

    return groups.isEmpty
        ? const SliverFillRemaining(
            child: EmptyScreen(
              label: "No Business Groups.\nCreate a Business Group",
            ),
          )
        : SliverList.builder(
            key: const Key("groupsList"),

            // padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
            // physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            itemBuilder: (context, index) => Column(
                  children: [
                    CollectionWidget(
                      key: ObjectKey(groups[index]),
                      group: groups[index],
                    ),
                    if (index == groups.length - 1)
                      const Gap(SizeManager.bottomBarHeight)
                    else
                      Divider(
                        thickness: 0.8,
                        color: ColorManager.secondary.withOpacity(0.08),
                      )
                  ],
                ),
            itemCount: groups.length);
  }
}
