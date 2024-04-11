import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';


/// This is a state Provider, responsible for returning and refreshing
/// the Group Repo class. Inorder reload to be on the safer side when looking for changes.
final groupRepoProvider = StateProvider<GroupRepo>((ref) => GroupRepo());

/// The Future provider that helps us to perform
/// The Future task of getting Groups.
final groupsFutureProvider =
    FutureProvider<List<dynamic>>((ref) async {
  final groupRepo = ref.watch(groupRepoProvider);
  final data = await groupRepo.getGroupsJson();
  log("Loaded data from groupRepo");
  return data;
});

/// The StreamProvider that constantly sends updates
/// Of the Groups States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final groupsStreamProvider = StreamProvider.autoDispose<List<Group>>(
  (ref) {
    final streamController = StreamController<List<Group>>();

    final periodic = Timer.periodic(const Duration(seconds: 4), (_) {
      ref.watch(groupsFutureProvider).whenData((groupsJson) {
        final _groupList =
            AppStorage.getGroups().map((e) => e.toJson()).toList();
        final bool groupsDifferent =
            json.encode(_groupList) != json.encode(groupsJson);
        List groupsListJson = groupsJson;
        List<Group> groupsList =
              groupsListJson.map((e) => Group.fromJson(json: e)).toList();

        log("Data Group Names from API: ${groupsList.map((e) => e.groupName).toList()}");
        log("Data Group Names from Cache: ${AppStorage.getGroups().map((e) => e.groupName).toList()}/n");

        log("Data is different : $groupsDifferent");

        if (groupsDifferent) {
          // Only if Data is not the same

          log("New Groups from API ${groupsList.map((e) => e.groupName).toList().where((element) => !AppStorage.getGroups().map((e) => e.groupName).toList().contains(element)).toList()}");
          log("Groups Newly Saved to Cache ${groupsList.map((e) => e.groupName).toList().where((element) => !AppStorage.getGroups().map((e) => e.groupName).toList().contains(element)).toList()}");
          log("Are the groups now in sync ? ${groupsList.map((e) => e.groupName).toList() == AppStorage.getGroups().map((e) => e.groupName).toList()}");
          AppStorage.saveGroups(groups: groupsList);

          streamController.sink.add(groupsList);
        }
        ref.read(groupRepoProvider.notifier).state = GroupRepo();
        log("==================");
      });
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
