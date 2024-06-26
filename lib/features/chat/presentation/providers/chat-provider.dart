// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

/// This is a state Provider, responsible for returning and refreshing
/// the Chat Repo class. Inorder reload to be on the safer side when looking for changes.
final chatsRepoProvider = StateProvider<ChatRepo>(
  (ref) => ChatRepo(),
);

/// The Future provider that helps us to perform
/// The Future task of getting Chats.
final chatsListProvider =
    FutureProvider.family<List<dynamic>, String>((ref, groupId) async {
  final chatsRepo = ref.watch(chatsRepoProvider);
  final chats = await chatsRepo.getChats(groupId: groupId);
  // log("Loaded data from Chats Repo");
  return chats;
});

/// The [chatsGroupProvider] is responsible for passing
/// The [Group.groupId] that will be used to communicate during chats
final chatsGroupProvider = StateProvider<String>((ref) {
  /// By default, to be on the first group from the cache.
  /// After all, A Chat screen can't be opened if there are no Groups.
  /// And there are no groups if there're no groups on the cache.
  return AppStorage.getGroups()[0].groupId;
});

/// The StreamProvider that constantly sends updates
/// Of the Chats States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final chatsStreamProvider = StreamProvider.autoDispose<List<Chat>>(
  (ref) {
    final StreamController<List<Chat>> streamController =
        StreamController<List<Chat>>();
    final String groupId = ref.watch(chatsGroupProvider);

    final periodic =
        Timer.periodic(const Duration(milliseconds: 2025), (timer) {
      ref.watch(chatsListProvider(groupId)).whenData((chatsJson) {
        final _chatsList = AppStorage.getChats(groupId: groupId)
            .map((e) => e.toJson())
            .toList();

        final bool chatsAreDifferent =
            json.encode(_chatsList) != json.encode(chatsJson)  || _chatsList.length != chatsJson.length;
        List chatsListJson = chatsJson;
        List<Chat> chatsList =
            chatsListJson.map((e) => Chat.fromJson(json: e)).toList();

        // log("Data Chat Names from API: ${chatsList.map((e) => e.message).toList()}");
        // log("Data Chat Names from Cache: ${AppStorage.getChats(groupId: groupId).map((e) => e.message).toList()}/n");

        // log("Data is different : $chatsAreDifferent");

        if (chatsAreDifferent) {
          // Only if Data is not the same

          // log("New Chats from API ${chatsList.map((e) => e.message).toList().where((element) => !AppStorage.getChats(groupId: groupId).map((e) => e.message).toList().contains(element)).toList()}");
          // log("Chats Newly Saved to Cache ${chatsList.map((e) => e.message).toList().where((element) => !AppStorage.getChats(groupId: groupId).map((e) => e.message).toList().contains(element)).toList()}");
          // log("Are the chats now in sync ? ${chatsList.map((e) => e.message).toList() == AppStorage.getChats(groupId: groupId).map((e) => e.message).toList()}");

          AppStorage.saveChats(chats: chatsList, groupId: groupId);

          streamController.sink.add(chatsList);
        }
        ref.read(chatsRepoProvider.notifier).state = ChatRepo();
        // log("==================");
      });
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
