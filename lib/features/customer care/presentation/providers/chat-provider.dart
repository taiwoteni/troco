// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/customer%20care/domain/repositories/customer-care-repository.dart';

/// This is a state Provider, responsible for returning and refreshing
/// the Chat Repo class. Inorder reload to be on the safer side when looking for changes.
final customerCareRepoProvider = StateProvider<CustomerCareRepository>(
  (ref) => CustomerCareRepository(),
);

/// The Future provider that helps us to perform
/// The Future task of getting Chats.
final chatsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final chatsRepo = ref.watch(customerCareRepoProvider);
  final chats = await chatsRepo.getCustomerCareMessages(
      sessionId: AppStorage.getCustomerCareSessionId() ?? "??????");
  // log("Loaded data from Chats Repo");
  return chats;
});

/// The StreamProvider that constantly sends updates
/// Of the Chats States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final chatsStreamProvider = StreamProvider.autoDispose<List<Chat>>(
  (ref) {
    final StreamController<List<Chat>> streamController =
        StreamController<List<Chat>>();

    final periodic =
        Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      ref.watch(chatsListProvider).whenData((chatsJson) {
        final _chatsList =
            AppStorage.getCustomerCareChats().map((e) => e.toJson()).toList();

        final bool chatsAreDifferent =
            json.encode(_chatsList) != json.encode(chatsJson) ||
                _chatsList.length != chatsJson.length;
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

          AppStorage.saveCustomerCareChats(chats: chatsList);

          streamController.sink.add(chatsList);
        }
        ref.read(customerCareRepoProvider.notifier).state =
            CustomerCareRepository();
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
