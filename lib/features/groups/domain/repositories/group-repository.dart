import 'dart:developer';

import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/api/data/model/response-model.dart';

class GroupRepo {
  static Future<HttpResponseModel> createGroup(
      {required final String groupName,
      required final bool useDelivery,
      required final String deadlineTime,
      required final String userId}) async {
    final result = await ApiInterface.postRequest(
        url: "creategroup/$userId",
        okCode: 201,
        data: {
          "groupName": groupName,
          "useDelivery": useDelivery,
          "deadlineTime": deadlineTime,
        });
    return result;
  }

  static Future<HttpResponseModel> addMember({
    required final String groupId,
    required final String userId,
  }) async {
    final result =
        await ApiInterface.patchRequest(url: "addUserToGroup", data: {
      "groupId": groupId,
      "memberId": userId,
      "userId": ClientProvider.readOnlyClient!.userId
    });
    return result;
  }

  Future<List<dynamic>> getGroupsJson() async {
    final result = await ApiInterface.getRequest(
        url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if (!result.error) {
      Map<dynamic, dynamic> userJson = result.messageBody!["data"];
      // log(userJson.toString());
      List userGroupsList = userJson["groups"];
      return userGroupsList;
    }
    log(result.body.toString());
    return AppStorage.getGroups().map((e) => e.toJson()).toList();
  }
}
