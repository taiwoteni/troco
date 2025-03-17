import 'dart:convert';

import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../auth/domain/entities/client.dart';
import '../entities/group.dart';

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

  static Future<HttpResponseModel> deleteGroup({
    required final String userId,
    required final String groupId,
  }) async {
    final request =
        await ApiInterface.deleteRequest(url: "deletegroup/$userId/$groupId");

    return request;
  }

  Future<List<dynamic>> getGroupsJson() async {
    final result = await getGroupsOneTime();

    if (result.error) {
      return AppStorage.getGroups().map((e) => e.toJson()).toList();
    }

    return (result.messageBody?["data"] ?? []) as List;
  }

  static Future<HttpResponseModel> getGroupsOneTime() async {
    return getUserGroups(userId: ClientProvider.readOnlyClient?.userId ?? "");
  }

  static Future<HttpResponseModel> getUserGroups(
      {required final String userId}) async {
    var response = await ApiInterface.getRequest(url: "user/$userId/groups");

    if (response.error) {
      return HttpResponseModel(
          error: true,
          body: jsonEncode({"message": "Groups not found"}),
          code: 400);
    }

    Map<dynamic, dynamic> userJson = response.messageBody ?? {};
    List userGroupsList = userJson["groups"] ?? [];
    final groupsList = userGroupsList
        .map(
          (e) => Group.fromJson(json: e),
        )
        .toList();
    final sortedGroupsList = <Map<dynamic, dynamic>>[];
    final cachedGroupsList = [];

    /// We are trying to get and save all the firstName,lastName,userImage and Id;
    /// And also send all unsent Chats in a group
    for (final group in groupsList) {
      Group g = group;

      /// Now, im trying to save the user's details seperately on my end.
      /// Only if the members have changed
      /// First check if the cachedGroupsList contains this group

      final containsGroup =
          cachedGroupsList.map((e) => e.groupId).contains(group.groupId);
      if (containsGroup) {
        final cachedGroup = cachedGroupsList.firstWhere(
          (element) => element.groupId == group.groupId,
        );

        /// If it contains this group, we then check if the members are the same;
        final sameMembers = group.members.every(
          (element) =>
              cachedGroup.sortedMembers.map((e) => e.userId).contains(element),
        );

        /// If it contains this sameMembers then we just assign it to the sortedGroup already stored in cache.
        if (sameMembers) {
          // Intentionaly not assign it directly as, messages (chats) may differ
          final gJson = g.toJson();
          gJson["sortedMembers"] = cachedGroup.toJson()["sortedMembers"];
          g = Group.fromJson(json: gJson);
        } else {
          g = await _getMembersDetailsInGroup(group: group);
        }
      } else {
        g = await _getMembersDetailsInGroup(group: group);
      }

      sortedGroupsList.add(g.toJson());
    }

    return HttpResponseModel(
        error: false,
        body: jsonEncode({"message": "Groups Found", "data": sortedGroupsList}),
        code: response.code);
  }

  static Future<Group> _getMembersDetailsInGroup(
      {required final Group group}) async {
    final fullMembersList = <Client>[];
    final friends = AppStorage.getFriends();
    final membersList = group.members
        .where((element) => element.toString() != group.adminId)
        .toList();
    for (final userId in membersList) {
      if (friends.any(
        (element) => element.userId == userId,
      )) {
        final friend = friends.firstWhere(
          (element) => element.userId == userId,
        );

        final clientJson = {
          "id": friend.userId,
          "firstName": friend.firstName,
          "lastName": friend.lastName,
          "userImage": friend.profile
        };
        fullMembersList.add(Client.fromJson(json: clientJson));
        continue;
      }
      var clientJson = {};
      if (userId == ClientProvider.readOnlyClient?.userId) {
        clientJson = {
          "id": ClientProvider.readOnlyClient?.userId,
          "firstName": ClientProvider.readOnlyClient?.firstName,
          "lastName": ClientProvider.readOnlyClient?.lastName,
          "userImage": ClientProvider.readOnlyClient?.profile
        };
      } else {
        clientJson = {
          "id": userId,
          "firstName": "Loading",
          "lastName": "Name...",
          "userImage": "null"
        };
      }

      fullMembersList.add(Client.fromJson(json: clientJson));
    }
    // We add the admin as a client as well. Although it's wrong :)
    fullMembersList.add(Client.fromJson(json: {
      "id": group.adminId,
      "firstName": "Admin",
      "lastName": "",
      "userImage": null
    }));

    final groupJson = group.toJson();
    groupJson["sortedMembers"] = fullMembersList
        .map(
          (e) => e.toJson(),
        )
        .toList();

    final sortedGroup = Group.fromJson(json: groupJson);

    return sortedGroup;
  }

  static Future<HttpResponseModel> leaveGroup(
      {required final String userId, required final Group group}) async {
    final response = await ApiInterface.patchRequest(
        url: "leavegroup/$userId/${group.groupId}", data: {});
    return response;
  }
}
