import 'dart:convert';

import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/cache/shared-preferences.dart';
import '../../../auth/domain/entities/client.dart';

class FriendRepository {
  static Future<HttpResponseModel> addFriend(
      {required final Client client}) async {
    final response = await ApiInterface.patchRequest(
        url:
            "addfriend/${ClientProvider.readOnlyClient!.userId}/${client.userId}",
        data: {});
    return response;
  }

  static Future<HttpResponseModel> removeFriend(
      {required final Client client}) async {
    final response = await ApiInterface.patchRequest(
        url:
            "removefriend/${ClientProvider.readOnlyClient!.userId}/${client.userId}",
        data: {});
    return response;
  }

  Future<List<Client>> getFriends() async {
    final friends = <Client>[];

    final clientJson = AppStorage.getUser()!.toJson();
    final userFriends = (clientJson["friends"] ?? []) as List;

    for (final String friend in userFriends) {
      final response = await ApiInterface.findUser(userId: friend);
      if (!response.error) {
        final userJson = response.messageBody!["data"] as Map<dynamic, dynamic>;

        // To remove bulky data
        userJson.remove("transactions");
        userJson.remove("groups");
        userJson.remove("notifications");

        final friendClient = Client.fromJson(json: userJson);
        friends.add(friendClient);
      }
    }

    if (friends.isEmpty) {
      return AppStorage.getFriends();
    }

    return friends;
  }

  static Future<HttpResponseModel> getUsersFriends(
      {required final String userId}) async {
    final friends = <Map<dynamic, dynamic>>[];
    final res = await ApiInterface.findUser(userId: userId);
    if (res.error) {
      return res;
    }

    final clientJson = res.messageBody!["data"];
    final userFriends = (clientJson["friends"] ?? []) as List;

    for (final String friend in userFriends) {
      final response = await ApiInterface.findUser(userId: friend);
      if (!response.error) {
        final userJson = response.messageBody!["data"] as Map<dynamic, dynamic>;

        // To remove bulky data
        userJson.remove("transactions");
        userJson.remove("groups");
        userJson.remove("notifications");

        friends.add(userJson);
      }
    }

    return HttpResponseModel(
        error: false,
        body: jsonEncode(
            {"message": res.messageBody?["message"], "data": friends}),
        code: res.code);
  }
}
