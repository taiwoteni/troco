// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';
import '../../../../chat/domain/entities/chat.dart';
import '../../../../chat/presentation/providers/chat-provider.dart';

/// This is a state Provider, responsible for returning and refreshing
/// the Group Repo class. Inorder reload to be on the safer side when looking for changes.
final groupRepoProvider = StateProvider<GroupRepo>((ref) => GroupRepo());

final groupsListProvider =
    StateProvider<List<Group>>((ref) => AppStorage.getGroups());

/// The Future provider that helps us to perform
/// The Future task of getting Groups.
final groupsFutureProvider = FutureProvider<List<dynamic>>((ref) async {
  final groupRepo = ref.watch(groupRepoProvider);
  final data = await groupRepo.getGroupsJson();
  // log(data.toString());
  // log("Loaded data from groupRepo");
  return data;
});

/// The StreamProvider that constantly sends updates
/// Of the Groups States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final groupsStreamProvider = StreamProvider<List<Group>>(
  (ref) {
    final streamController = StreamController<List<Group>>();

    final periodic = Timer.periodic(const Duration(seconds: 2), (_) {
      ref.watch(groupsFutureProvider).when(
          data: (groupsJson) {
            /// First of all we have to compare and contrast between the
            /// values gotten from the APIs and saved on the Device Cache.
            ///
            /// We compare and contrast the group itself, it's messages and it's members
            /// since that's what we're watching for.
            ///
            /// We extract the Lists. Lists starting with underscores ('_') are from the Cache.
            /// While the others are from the [groupsJson];

            /// We get the groupsList from the Cache
            final _groupList =
                AppStorage.getGroups().map((e) => e.toJson()).toList();

            /// We get the messages list from both the cache and the api's json data
            final _messagesList = _groupList.map((e) => e["messages"]).toList();
            final messagesList = groupsJson.map((e) => e["messages"]).toList();

            /// We get the members list from both the cache and the api's json data
            final _membersList = _groupList.map((e) => e["members"]).toList();
            final membersList = groupsJson.map((e) => e["members"]).toList();

            /// Then We contrast.
            final bool groupsDifferent =
                json.encode(_groupList) != json.encode(groupsJson) ||
                    _groupList.length != groupsJson.length;
            final bool messagesDifferent =
                json.encode(_messagesList) != json.encode(messagesList) ||
                    _messagesList.length != messagesList.length;
            final bool membersDifferent =
                json.encode(_membersList) != json.encode(membersList) ||
                    _membersList.length != membersList.length;

            final valuesAreDifferent =
                groupsDifferent || messagesDifferent || membersDifferent;

            List<Group> groupsList = groupsJson
                .map((e) => Group.fromJson(json: e))
                // .where(
                //   (group) => group.members
                //       .contains(ClientProvider.readOnlyClient!.userId),
                // )
                .toList();

            groupsList.sort(
              (a, b) => b.createdTime.compareTo(a.createdTime),
            );

            // log("Data Group Names from API: ${groupsList.map((e) => e.groupName).toList()}");
            // log("Data Group Names from Cache: ${AppStorage.getGroups().map((e) => e.groupName).toList()}/n");

            // log("Data is different : $groupsDifferent");

            if (valuesAreDifferent) {
              log("");
              log("Groups have changed");
              log("");

              // Only if Data is not the same

              // log("New Groups from API ${groupsList.map((e) => e.groupName).toList().where((element) => !AppStorage.getGroups().map((e) => e.groupName).toList().contains(element)).toList()}");
              // log("Groups Newly Saved to Cache ${groupsList.map((e) => e.groupName).toList().where((element) => !AppStorage.getGroups().map((e) => e.groupName).toList().contains(element)).toList()}");
              // log("Are the groups now in sync ? ${groupsList.map((e) => e.groupName).toList() == AppStorage.getGroups().map((e) => e.groupName).toList()}");
              AppStorage.saveGroups(groups: groupsList);

              ///Only saving chats if the group isn't opened by the user.
              ///The concurrent modification doesn't allow the chat-provider
              ///to know that chats have changed.

              for (final group in groupsList) {
                if (group.groupId != ref.watch(chatsGroupProvider)) {
                  final groupJson = group.toJson();
                  final chats = ((groupJson["messages"] ?? []) as List)
                      .map((e) => Chat.fromJson(json: e))
                      .toList();
                  // if(chatProvide)
                  AppStorage.saveChats(chats: chats, groupId: group.groupId);
                }
              }
              ref.read(groupsListProvider.notifier).state = groupsList;
              streamController.sink.add(groupsList);
            }
            ref.watch(groupRepoProvider.notifier).state = GroupRepo();
            // log("==================");
          },
          error: (error, stackTrace) {
            // log("Error occured when getting groups from api $error");
            log("Error occured when getting groups from api $error",
                stackTrace: stackTrace);
          },
          loading: () => null);
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
