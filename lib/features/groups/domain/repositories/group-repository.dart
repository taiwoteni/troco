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
    final result = await ApiInterface.getRequest(
        url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if (!result.error) {
      Map<dynamic, dynamic> userJson = result.messageBody!["data"];
      List userGroupsList = userJson["groups"];

      final groupsList = userGroupsList
          .map(
            (e) => Group.fromJson(json: e),
          )
          .toList();
      final sortedGroupsList = <Group>[];
      final cachedGroupsList = AppStorage.getGroups();

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
          final sameMembers = cachedGroup.members.every(
            (element) => group.members.contains(element),
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

        sortedGroupsList.add(g);
      }

      return sortedGroupsList
          .map(
            (e) => e.toJson(),
          )
          .toList();
    }
    // log(result.body.toString());
    return AppStorage.getGroups().map((e) => e.toJson()).toList();
  }

  Future<Group> _getMembersDetailsInGroup({required final Group group}) async {
    final fullMembersList = <Client>[];
    final membersList = group.members
        .where((element) => element.toString() != group.adminId)
        .toList();
    for (final userId in membersList) {
      final searchResponse = await ApiInterface.findUser(userId: userId);
      // log(searchResponse.body);
      if (!searchResponse.error) {
        final userJson = searchResponse.messageBody!["data"];
        final clientJson = {
          "id": userJson["_id"],
          "firstName": userJson["firstName"],
          "lastName": userJson["lastName"],
          "userImage": userJson["userImage"]
        };
        fullMembersList.add(Client.fromJson(json: clientJson));
      }
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
}
