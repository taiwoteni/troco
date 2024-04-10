import 'dart:developer';

import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../core/api/data/model/response-model.dart';

class GroupRepo{
  static Future<HttpResponseModel> createGroup(
      {
        required final String groupName,
        required final bool useDelivery,
        required final String deadlineTime,
        required final String userId}) async {
    final result = await ApiInterface.postRequest(
        url: "creategroup/$userId", 
        okCode: 201,
        data: {
          "groupName": groupName,
          "useDelivery":useDelivery,
          "deadlineTime":deadlineTime,
          });
    return result;
  }
  Future<List<Group>> getGroups()async{
    final result = await ApiInterface.getRequest(url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if(!result.error){
      List groupListJson = result.messageBody!["data"]["groups"];
      List<Group> groups = groupListJson.map((groupJson) => Group.fromJson(json: groupJson)).toList();
      return groups;
    }
    log(result.body.toString());
    return [];
  }
}