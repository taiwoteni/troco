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

  Future<List<dynamic>> getGroupsJson() async {
    final result = await ApiInterface.getRequest(
        url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if (!result.error) {
      Map<dynamic, dynamic> userJson = result.messageBody!["data"];
      List userGroupsList = userJson["groups"];
      // log(userGroupsList.toString());

      final groupsList = userGroupsList
          .map(
            (e) => Group.fromJson(json: e),
          )
          .toList();
      final sortedGroupsList = <Group>[];

      /// We are trying to get and save all the firstName,lastName,userImage and Id;
      for (final group in groupsList) {
        /// Now, im trying to save the user's details seperately on my end.
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

        sortedGroupsList.add(Group.fromJson(json: groupJson));
      }

      // /// Now i want to also locally store transactions from a group
      // for(int i=0; i<sortedGroupsList.length; i++){
      //   final group = groupsList[i];
      //   final groupJson = group.toJson();
      //   if(group.hasTransaction){
      //     final transactionResponse = await TransactionRepo.getOneTransaction(transactionId: groupJson["transactions"][0]);
          
      //     if(!transactionResponse.error){
      //       groupJson["transaction"]=transactionResponse.messageBody!["data"];
      //     }
      //     sortedGroupsList[i] = Group.fromJson(json: groupJson);
      //   }
      // }

      // log(userJson.toString());
      return sortedGroupsList
          .map(
            (e) => e.toJson(),
          )
          .toList();
    }
    // log(result.body.toString());
    return AppStorage.getGroups().map((e) => e.toJson()).toList();
  }
}
