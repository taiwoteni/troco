// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';

import '../../domain/entities/notification.dart';


/// This is a state Provider, responsible for returning and refreshing
/// the Notification Repo class. Inorder reload to be on the safer side when looking for changes.
final notificationRepoProvider =
    StateProvider<NotificationRepo>((ref) => NotificationRepo());

/// The Future provider that helps us to perform
/// The Future task of getting Notifications.
final notificationFutureProvider =
    FutureProvider<List<Map<dynamic, dynamic>>>((ref) async {
  final notificationRepo = ref.watch(notificationRepoProvider);
  final data = await notificationRepo.getNotifications();
  // log(data.toString());
  // log("Loaded data from notificationRepo");
  return data.map((e) => e.toJson()).toList();
});

/// The StreamProvider that constantly sends updates
/// Of the Notification States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final notificationsStreamProvider = StreamProvider<List<Notification>>(
  (ref) {
    final streamController = StreamController<List<Notification>>();

    final periodic = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.watch(notificationFutureProvider).when(
          data: (notificationsJson) {

            /// First of all we have to compare and contrast between the
            /// values gotten from the APIs and saved on the Device Cache.
            ///
            /// We compare and contrast the transaction itself.
            ///
            /// We extract the Lists. Lists starting with underscores ('_') are from the Cache.
            /// While the others are from the [transactionsJson];

            /// We get the transactionsList from the Cache
            final _notificationsList =
                AppStorage.getNotifications().map((e) => e.toJson()).toList();

            /// Then We contrast.
            final bool notificationsDifferent =
                json.encode(_notificationsList) != json.encode(notificationsJson);

            final valuesAreDifferent = notificationsDifferent;

            
            if (valuesAreDifferent) {
              List<Notification> notificationsList = notificationsJson
                .map((e) => Notification.fromJson(json: e))
                .toList();


              AppStorage.saveNotifications(notifications: notificationsList);
              streamController.sink.add(notificationsList);
            }
            ref.watch(notificationRepoProvider.notifier).state =
                NotificationRepo();
            // log("==================");
          },
          error: (error, stackTrace) =>
              log("Error occured when getting notification from api $error"),
          loading: () => null);
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
