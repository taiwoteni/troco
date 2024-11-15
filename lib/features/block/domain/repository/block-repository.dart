import 'package:troco/core/cache/shared-preferences.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/api/data/repositories/api-interface.dart';
import '../../../auth/domain/entities/client.dart';
import '../../../auth/presentation/providers/client-provider.dart';

class BlockRepository {
  static Future<HttpResponseModel> blockUser(
      {required final String userId, required final String reason}) async {
    final response = await ApiInterface.patchRequest(
        url:
            "block_fellow_user/${ClientProvider.readOnlyClient!.userId}/$userId",
        data: {"reason": reason});

    return response;
  }

  Future<List<Client>> getBlockedUsers() async {
    final response = await ApiInterface.getRequest(
        url: "getblockedusers/${ClientProvider.readOnlyClient?.userId}");

    if (response.error) {
      return AppStorage.getBlockedUsers();
    }

    return (response.messageBody!["data"] as List)
        .map((e) => Client.fromJson(json: e))
        .toList();
  }

  static Future<HttpResponseModel> unblockUser(
      {required final String userId, required final String reason}) async {
    final response = await ApiInterface.patchRequest(
        url:
            "unblock_fellow_user/${ClientProvider.readOnlyClient!.userId}/$userId",
        data: {"reason": reason});

    return response;
  }
}
