// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import '../providers/groups-provider.dart';
import 'groups-list.dart';

class CollectionsTab extends ConsumerStatefulWidget {
  const CollectionsTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends ConsumerState<CollectionsTab> {
  bool hasShownError = false;
  @override
  Widget build(BuildContext context) {
    // final asyncConfig = ref.watch(groupsStreamProvider);
    return ref.watch(groupsStreamProvider).when(data: (data) {
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
                "An unknown error occurred. Check your internet connection.");
      }
      log("Error occurred in group listener in build method: $error");
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
