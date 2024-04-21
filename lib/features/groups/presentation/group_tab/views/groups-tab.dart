import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../widgets/empty-screen.dart';
import '../widgets/group-widget.dart';
import '../providers/groups-provider.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  bool hasShownError = false;
  @override
  Widget build(BuildContext context) {
    // final asyncConfig = ref.watch(groupsStreamProvider);
    return ref.watch(groupsStreamProvider).when(
      data: (data) {
      log("rebuilt data: ${data.map((e) => e.groupName).toList()}");
      data.sort(
        (a, b) => b.createdTime.compareTo(a.createdTime),
      );
      return GroupList(groups: data.map((e) => e).toList());
    }, error: (error, stackTrace) {
      if (!hasShownError) {
        hasShownError = true;
        SnackbarManager.showBasicSnackbar(
            context: context,
            message:
                "An unknown error occured. Check your internet connection.");
      }
      log("Error occured in group listener in build method: $error");
      final groups = AppStorage.getGroups();
      groups.sort(
        (a, b) => b.createdTime.compareTo(a.createdTime),
      );
      return GroupList(groups: groups);
    }, loading: () {
      final groups = AppStorage.getGroups();
      groups.sort(
        (a, b) => b.createdTime.compareTo(a.createdTime),
      );
      return GroupList(groups: groups);
    });
  }
}

class GroupList extends StatefulWidget {
  final List<Group> groups;
  const GroupList({super.key, required this.groups});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return widget.groups.isEmpty
        ? const EmptyScreen(
            label: "No Business Groups.\nCreate a Business Group",
          )
        : ListView.separated(
            key: const Key("groupsList"),
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => Column(
                  children: [
                    ChatContactWidget(
                      key: ObjectKey(widget.groups[index]),
                      group: widget.groups[index],
                    ),
                    if (index == widget.groups.length - 1)
                      const Gap(SizeManager.bottomBarHeight),
                  ],
                ),
            separatorBuilder: (context, index) => Divider(
                  thickness: 0.8,
                  color: ColorManager.secondary.withOpacity(0.08),
                ),
            itemCount: widget.groups.length);
  }
}
