// This is a state Provider, responsible for returning and refreshing
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/block/domain/repository/block-repository.dart';
import 'package:troco/features/groups/domain/repositories/friend-repository.dart';

import '../../../../../core/cache/shared-preferences.dart';
import '../../../auth/domain/entities/client.dart';

/// the Friend Repo class. Inorder reload to be on the safer side when looking for changes.
final blockedUsersProvider =
    StateProvider<BlockRepository>((ref) => BlockRepository());

/// The Future provider that helps us to perform
/// The Future task of getting Referrals.
final blockedUsersFutureProvider =
    FutureProvider<List<Map<dynamic, dynamic>>>((ref) async {
  final blockRepo = ref.watch(blockedUsersProvider);
  final data = await blockRepo.getBlockedUsers();
  return data
      .map(
        (e) => e.toJson(),
      )
      .toList();
});

/// The StreamProvider that constantly sends updates
/// Of the Referrals  only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final blockedUsersStreamProvider = StreamProvider<List<Client>>(
  (ref) {
    final streamController = StreamController<List<Client>>();

    final periodic = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.watch(blockedUsersFutureProvider).when(
          data: (blockedUsersJson) {
            /// First of all we have to compare and contrast between the
            /// values gotten from the APIs and saved on the Device Cache.
            ///
            /// We compare and contrast the friends itself.
            ///
            /// We extract the Lists. Lists starting with underscores ('_') are from the Cache.
            /// While the others are from the [friendsJson];

            /// We get the transactionsList from the Cache
            final _blockedUsersList =
                AppStorage.getBlockedUsers().map((e) => e.toJson()).toList();

            /// Then We contrast.
            final bool blockedUsersDifferent =
                json.encode(_blockedUsersList) != json.encode(blockedUsersJson);

            final valuesAreDifferent = blockedUsersDifferent;

            List<Client> blockedUsersList =
                blockedUsersJson.map((e) => Client.fromJson(json: e)).toList();

            if (valuesAreDifferent) {
              AppStorage.saveBlockedUsers(clients: blockedUsersList);
              streamController.sink.add(blockedUsersList);
            }
            ref.watch(blockedUsersProvider.notifier).state = BlockRepository();
          },
          error: (error, stackTrace) =>
              log("Error occured when getting transactions from api $error"),
          loading: () => null);
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
