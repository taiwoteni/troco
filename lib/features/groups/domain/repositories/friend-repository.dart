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

        final friendClient = Client.fromJson(json: userJson);
        friends.add(friendClient);
      }
    }

    if (friends.isEmpty) {
      return AppStorage.getFriends();
    }

    return friends;
  }
}
