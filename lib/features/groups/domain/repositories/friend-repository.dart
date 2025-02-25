import 'dart:convert';

import 'package:troco/core/api/data/repositories/api-interface.dart';
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
    final response = await getUsersFriends(
        userId: ClientProvider.readOnlyClient?.userId ?? "");

    if (response.error) {
      return AppStorage.getFriends();
    }

    final results = (response.messageBody?["data"] ?? []) as List;

    return results
        .map(
          (e) => Client.fromJson(json: e),
        )
        .toList();
  }

  static Future<HttpResponseModel> getUsersFriends(
      {required final String userId}) async {
    final res = await ApiInterface.getRequest(url: "user/$userId/friends");
    if (res.error) {
      return HttpResponseModel(
          error: false,
          body: jsonEncode({"message": "Could not get friends"}),
          code: 400);
    }

    final userFriends = (res.messageBody?["friends"] ?? []) as List;
    final friends = userFriends
        .map(
          (e) => e,
        )
        .toList();

    return HttpResponseModel(
        error: false,
        body: jsonEncode(
            {"message": res.messageBody?["message"], "data": friends}),
        code: res.code);
  }
}
